classdef PGG327FinalExam < matlab.apps.AppBase
    %PGG327FINALEXAM App Designer app -- Step 11 (complete except Sensitivity,
    %   which is deliberately deferred to Step 12 since it depends on
    %   engine functions not yet built).
    %
    %   Tabs implemented: 1 Case Definition, 2 Survey & Validation,
    %   3 Wellpath, 4 Torque & Drag, 5 Telemetry Dashboard, 6 QC &
    %   Decision, 7 Stage Decision Log, 9 Export & Audit.
    %   Tab 8 (Sensitivity) will be inserted before Tab 9 in Step 12.
    %
    %   HOW TO GET THIS INTO A REAL .mlapp FILE:
    %     1. Open MATLAB, run appdesigner.
    %     2. File > New > Blank App.
    %     3. Click "Code View".
    %     4. Select all, delete, paste this file's contents in.
    %     5. File > Save As PGG327_FinalExam_40.mlapp (swap 40 for your
    %        real serial number once confirmed).
    %     6. Make sure engine/ and app/ are on your MATLAB path.
    %
    %   ARCHITECTURE RULE preserved throughout: every callback is THIN --
    %   it reads UI inputs, calls ONE (or a short, obvious sequence of)
    %   already-tested engine function(s), and writes results back to a
    %   UI property. No formulas live in this file.

    % ---- App shell ----
    properties (Access = public)
        UIFigure    matlab.ui.Figure
        TabGroup    matlab.ui.container.TabGroup
    end

    % ---- Tab 1: Case Definition ----
    properties (Access = public)
        Tab1_CaseDefinition           matlab.ui.container.Tab
        SerialNumberEditFieldLabel    matlab.ui.control.Label
        SerialNumberEditField         matlab.ui.control.NumericEditField
        MudWeightLabel                matlab.ui.control.Label
        FrictionFactorLabel           matlab.ui.control.Label
        HookLoadOffsetLabel           matlab.ui.control.Label
        EquipmentLimitsLabel          matlab.ui.control.Label
        AssumptionsTextAreaLabel      matlab.ui.control.Label
        AssumptionsTextArea           matlab.ui.control.TextArea
    end

    % ---- Tab 2: Survey & Validation ----
    properties (Access = public)
        Tab2_SurveyValidation         matlab.ui.container.Tab
        UploadDataButton              matlab.ui.control.Button
        ValidateButton                matlab.ui.control.Button
        RawSurveyTableLabel           matlab.ui.control.Label
        RawSurveyTable                matlab.ui.control.Table
        ValidationLogLabel            matlab.ui.control.Label
        ValidationLogTextArea         matlab.ui.control.TextArea
        CalculatedTrajectoryLabel     matlab.ui.control.Label
        CalculatedTrajectoryTable     matlab.ui.control.Table
    end

    % ---- Tab 3: Wellpath ----
    properties (Access = public)
        Tab3_Wellpath                 matlab.ui.container.Tab
        Trajectory3DAxes              matlab.ui.control.UIAxes
        DLSAxes                       matlab.ui.control.UIAxes
        RegionSummaryLabel            matlab.ui.control.Label
    end

    % ---- Tab 4: Torque & Drag ----
    properties (Access = public)
        Tab4_TorqueDrag               matlab.ui.container.Tab
        CalculateButton               matlab.ui.control.Button
        PickupSlackoffAxes            matlab.ui.control.UIAxes
        DragTorqueAxes                matlab.ui.control.UIAxes
        SurfaceValuesLabel            matlab.ui.control.Label
    end

    % ---- Tab 5: Telemetry Dashboard ----
    properties (Access = public)
        Tab5_TelemetryDashboard       matlab.ui.container.Tab
        CurrentStageLabel             matlab.ui.control.Label
        RunStageButton                matlab.ui.control.Button
        MechanicalTrendAxes           matlab.ui.control.UIAxes
        OperationalTrendAxes          matlab.ui.control.UIAxes
    end

    % ---- Tab 6: QC & Decision ----
    properties (Access = public)
        Tab6_QCDecision               matlab.ui.container.Tab
        StatusLampLabel               matlab.ui.control.Label
        StatusLamp                    matlab.ui.control.Lamp
        ControllingTriggerLabel       matlab.ui.control.Label
        UtilizationBarAxes            matlab.ui.control.UIAxes
        QCResultsTable                matlab.ui.control.Table
    end

    % ---- Tab 7: Stage Decision Log ----
    properties (Access = public)
        Tab7_StageDecisionLog         matlab.ui.container.Tab
        Tab7CurrentStageLabel         matlab.ui.control.Label
        StageDataSummaryTextArea      matlab.ui.control.TextArea
        Q1Label matlab.ui.control.Label
        Q1TextArea matlab.ui.control.TextArea
        Q2Label matlab.ui.control.Label
        Q2TextArea matlab.ui.control.TextArea
        Q3Label matlab.ui.control.Label
        Q3TextArea matlab.ui.control.TextArea
        Q4Label matlab.ui.control.Label
        Q4TextArea matlab.ui.control.TextArea
        Q5Label matlab.ui.control.Label
        Q5TextArea matlab.ui.control.TextArea
        Q6Label matlab.ui.control.Label
        Q6TextArea matlab.ui.control.TextArea
        ConfirmRationaleButton        matlab.ui.control.Button
        NextStageButton               matlab.ui.control.Button
        DecisionLogTable              matlab.ui.control.Table
    end

    % ---- Tab 8: Sensitivity ----
    properties (Access = public)
        Tab8_Sensitivity              matlab.ui.container.Tab
        RunSensitivityButton          matlab.ui.control.Button
        PickupSlackoffMuAxes          matlab.ui.control.UIAxes
        DragTorqueMuAxes              matlab.ui.control.UIAxes
        UncertaintyCaseDropDown       matlab.ui.control.DropDown
        UncertaintyResultLabel        matlab.ui.control.Label
        SensitivityResultsTable       matlab.ui.control.Table
    end

    % ---- Tab 9: Export & Audit ----
    properties (Access = public)
        Tab9_ExportAudit              matlab.ui.container.Tab
        ExportButton                  matlab.ui.control.Button
        ResetButton                   matlab.ui.control.Button
        ExportSummaryTextArea         matlab.ui.control.TextArea
    end

    % ---- App data (non-UI) ----
    properties (Access = private)
        BaseParams
        CaseDef
        SurveyRaw
        SurveyValid
        ValidationLog
        Trajectory
        TDResults
        Telemetry
        QCResults
        DecisionLog
        CurrentStage = 1
        SensitivityResults
    end

    methods (Access = private)

        %% ---------- Startup ----------
        function startupFcn(app)
            app.BaseParams = getBaseParameters();
            n = getStudentSerialNumber();
            app.CaseDef = buildCaseDefinition(n, app.BaseParams);

            app.SerialNumberEditField.Value = app.CaseDef.SerialNumber;
            app.MudWeightLabel.Text = sprintf('Personalized Mud Weight: %.4f ppg', app.CaseDef.MW_ppg);
            app.FrictionFactorLabel.Text = sprintf('Personalized Friction Factor: %.4f', app.CaseDef.mu);
            app.HookLoadOffsetLabel.Text = sprintf('Hook-Load Telemetry Offset: +%d kips', app.CaseDef.HLOffset_kips);
            app.EquipmentLimitsLabel.Text = sprintf(['Equipment Limits (UNCHANGED by personalization): ' ...
                'HL %.0f kips | Torque %.0f ft-lbf | SPP %.0f psi'], ...
                app.CaseDef.HLlimit_kips, app.CaseDef.Tlimit_ftlbf, app.CaseDef.SPPlimit_psi);
            app.AssumptionsTextArea.Value = {
                'Case Definition traceability panel (Section 4.3 of the exam).'
                ''
                'Serial number n personalizes mud weight, friction factor, and'
                'the hook-load telemetry offset via engine/buildCaseDefinition.m.'
                'Equipment limits are NEVER modified by personalization.'
                ''
                'Model-scope note: the torque-and-drag engine (Weeks 3-4) is a'
                'transparent first-order educational model -- no buckling,'
                'stiffness, curvature effects, or contact redistribution.'
                };

            % Telemetry is independent of survey validation -- load and
            % personalize it now so the dashboard/QC tabs are ready.
            app.Telemetry = applyPersonalizedTelemetry(getExaminationTelemetry(), app.CaseDef.HLOffset_kips);
            app.QCResults = initQCResultsTemplate();
            app.DecisionLog = initDecisionLogTemplate();
            app.CurrentStage = 1;
            updateStageIndicators(app);
        end

        %% ---------- Tab 2 callbacks ----------
        function UploadDataButtonPushed(app, ~)
            % Loads the fixed exam survey. Swap in uigetfile+readtable
            % here if you want a real file-picker for the video demo.
            app.SurveyRaw = getExaminationSurvey();
            app.RawSurveyTable.Data = app.SurveyRaw;
            app.ValidationLogTextArea.Value = {'Survey loaded. Click Validate to check it.'};
        end

        function ValidateButtonPushed(app, ~)
            if isempty(app.SurveyRaw)
                uialert(app.UIFigure, 'Upload survey data first.', 'No Data');
                return
            end

            [app.SurveyValid, app.ValidationLog] = validateSurvey(app.SurveyRaw);

            if height(app.ValidationLog) == 0
                app.ValidationLogTextArea.Value = {'No issues found -- all rows valid.'};
            else
                lines = strings(height(app.ValidationLog), 1);
                for k = 1:height(app.ValidationLog)
                    lines(k) = sprintf('Row %d [%s]: %s -> %s', ...
                        app.ValidationLog.RowIndex(k), app.ValidationLog.Field(k), ...
                        app.ValidationLog.Issue(k), app.ValidationLog.Action(k));
                end
                app.ValidationLogTextArea.Value = cellstr(lines);
            end

            app.Trajectory = computeMinimumCurvature(app.SurveyValid);
            app.CalculatedTrajectoryTable.Data = app.Trajectory;
            updateWellpathPlots(app);
        end

        %% ---------- Tab 3 helper ----------
        function updateWellpathPlots(app)
            cla(app.Trajectory3DAxes);
            plot3(app.Trajectory3DAxes, app.Trajectory.E_ft, app.Trajectory.N_ft, -app.Trajectory.TVD_ft, '-o');
            view(app.Trajectory3DAxes, 3);
            grid(app.Trajectory3DAxes, 'on');
            xlabel(app.Trajectory3DAxes, 'East (ft)');
            ylabel(app.Trajectory3DAxes, 'North (ft)');
            zlabel(app.Trajectory3DAxes, '-TVD (ft)');
            title(app.Trajectory3DAxes, '3D Well Trajectory');

            cla(app.DLSAxes);
            plot(app.DLSAxes, app.Trajectory.MD_ft, app.Trajectory.DLS_deg100ft, '-o');
            grid(app.DLSAxes, 'on');
            xlabel(app.DLSAxes, 'MD (ft)');
            ylabel(app.DLSAxes, 'DLS (deg/100ft)');
            title(app.DLSAxes, 'Dogleg Severity vs MD');

            regions = unique(app.Trajectory.Region, 'stable');
            app.RegionSummaryLabel.Text = sprintf('Regions identified (by MD order): %s', strjoin(regions, ' -> '));
        end

        %% ---------- Tab 4 callback + helper ----------
        function CalculateButtonPushed(app, ~)
            if isempty(app.Trajectory)
                uialert(app.UIFigure, 'Validate the survey first (Tab: Survey & Validation).', 'No Trajectory');
                return
            end
            app.TDResults = computeTorqueAndDrag(app.Trajectory, app.BaseParams.wAir_lbft, ...
                app.CaseDef.MW_ppg, app.CaseDef.mu, app.BaseParams.rEff_ft, app.BaseParams.steelDensity_ppg);
            updateTorqueDragPlots(app);
        end

        function updateTorqueDragPlots(app)
            cla(app.PickupSlackoffAxes);
            hold(app.PickupSlackoffAxes, 'on');
            plot(app.PickupSlackoffAxes, app.TDResults.MD_ft, app.TDResults.HL_PU_lb/1000, '-o', 'DisplayName', 'Pickup');
            plot(app.PickupSlackoffAxes, app.TDResults.MD_ft, app.TDResults.HL_SO_lb/1000, '-s', 'DisplayName', 'Slack-off');
            hold(app.PickupSlackoffAxes, 'off');
            legend(app.PickupSlackoffAxes, 'Location', 'best');
            grid(app.PickupSlackoffAxes, 'on');
            xlabel(app.PickupSlackoffAxes, 'MD (ft)');
            ylabel(app.PickupSlackoffAxes, 'Hook Load (kips)');
            title(app.PickupSlackoffAxes, 'Pickup / Slack-off Hook Load vs MD');

            cla(app.DragTorqueAxes);
            yyaxis(app.DragTorqueAxes, 'left');
            plot(app.DragTorqueAxes, app.TDResults.MD_ft, app.TDResults.cumDrag_lb, '-o');
            ylabel(app.DragTorqueAxes, 'Cumulative Drag (lb)');
            yyaxis(app.DragTorqueAxes, 'right');
            plot(app.DragTorqueAxes, app.TDResults.MD_ft, app.TDResults.cumTorque_ftlbf, '-s');
            ylabel(app.DragTorqueAxes, 'Cumulative Torque (ft-lbf)');
            grid(app.DragTorqueAxes, 'on');
            xlabel(app.DragTorqueAxes, 'MD (ft)');
            title(app.DragTorqueAxes, 'Cumulative Drag & Torque vs MD');

            surfacePU = app.TDResults.HL_PU_lb(end) / 1000;
            surfaceSO = app.TDResults.HL_SO_lb(end) / 1000;
            surfaceDrag = app.TDResults.cumDrag_lb(end);
            surfaceTorque = app.TDResults.cumTorque_ftlbf(end);
            app.SurfaceValuesLabel.Text = sprintf(['Model surface values -- Pickup: %.1f kips | Slack-off: %.1f kips | ' ...
                'Drag: %.0f lb | Torque: %.0f ft-lbf   (Limits: %.0f kips / %.0f ft-lbf -- this simplified ' ...
                'model is NOT expected to match telemetry exactly; see report limitations.)'], ...
                surfacePU, surfaceSO, surfaceDrag, surfaceTorque, app.CaseDef.HLlimit_kips, app.CaseDef.Tlimit_ftlbf);
        end

        %% ---------- Tab 5 callback + helper ----------
        function RunStageButtonPushed(app, ~)
            limits = struct('HLlimit_kips', app.CaseDef.HLlimit_kips, ...
                'Tlimit_ftlbf', app.CaseDef.Tlimit_ftlbf, ...
                'SPPlimit_psi', app.CaseDef.SPPlimit_psi);
            qcParams = struct('cautionLow', app.BaseParams.cautionLow, ...
                'criticalHigh', app.BaseParams.criticalHigh, ...
                'QoutCaution', app.BaseParams.QoutCaution, ...
                'QoutCritical', app.BaseParams.QoutCritical);

            qcRow = runQCForStage(app.Telemetry, app.CurrentStage, limits, qcParams);

            if ismember(app.CurrentStage, app.QCResults.Stage)
                app.QCResults(app.QCResults.Stage == app.CurrentStage, :) = qcRow;
            else
                app.QCResults = [app.QCResults; qcRow];
            end

            updateTelemetryDashboard(app);
            updateQCTab(app);
            updateStageSummaryPanel(app);
        end

        function updateTelemetryDashboard(app)
            slice = getTelemetrySlice(app.Telemetry, app.CurrentStage);

            normHL = slice.HookLoad_kips / app.CaseDef.HLlimit_kips;
            normT = slice.Torque_ftlbf / app.CaseDef.Tlimit_ftlbf;
            normSPP = slice.SPP_psi / app.CaseDef.SPPlimit_psi;
            normQout = slice.Qout_pct / 100;

            cla(app.MechanicalTrendAxes);
            hold(app.MechanicalTrendAxes, 'on');
            plot(app.MechanicalTrendAxes, slice.Stage, normHL, '-o', 'DisplayName', 'HL / limit');
            plot(app.MechanicalTrendAxes, slice.Stage, normT, '-s', 'DisplayName', 'Torque / limit');
            plot(app.MechanicalTrendAxes, slice.Stage, normSPP, '-^', 'DisplayName', 'SPP / limit');
            plot(app.MechanicalTrendAxes, slice.Stage, normQout, '-d', 'DisplayName', 'Qout / 100%');
            yline(app.MechanicalTrendAxes, 1.0, '--r', 'DisplayName', 'Limit (1.0)');
            hold(app.MechanicalTrendAxes, 'off');
            legend(app.MechanicalTrendAxes, 'Location', 'best');
            grid(app.MechanicalTrendAxes, 'on');
            xlabel(app.MechanicalTrendAxes, 'Stage');
            ylabel(app.MechanicalTrendAxes, 'Normalized (fraction of limit)');
            title(app.MechanicalTrendAxes, 'Safety-Relevant Indicators vs Stage');

            cla(app.OperationalTrendAxes);
            hold(app.OperationalTrendAxes, 'on');
            plot(app.OperationalTrendAxes, slice.Stage, slice.RPM, '-o', 'DisplayName', 'RPM');
            plot(app.OperationalTrendAxes, slice.Stage, slice.WOB_klbf, '-s', 'DisplayName', 'WOB (klbf)');
            plot(app.OperationalTrendAxes, slice.Stage, slice.ROP_fthr, '-^', 'DisplayName', 'ROP (ft/hr)');
            hold(app.OperationalTrendAxes, 'off');
            legend(app.OperationalTrendAxes, 'Location', 'best');
            grid(app.OperationalTrendAxes, 'on');
            xlabel(app.OperationalTrendAxes, 'Stage');
            ylabel(app.OperationalTrendAxes, 'Value');
            title(app.OperationalTrendAxes, 'Operational Indicators vs Stage');
        end

        %% ---------- Tab 6 helper ----------
        function updateQCTab(app)
            currentRow = app.QCResults(app.QCResults.Stage == app.CurrentStage, :);

            switch currentRow.Status
                case "SAFE"
                    app.StatusLamp.Color = [0 0.6 0];
                case "CAUTION"
                    app.StatusLamp.Color = [0.9 0.6 0];
                case "CRITICAL"
                    app.StatusLamp.Color = [0.8 0 0];
            end
            app.ControllingTriggerLabel.Text = sprintf('Stage %d Status: %s | Controlling: %s', ...
                currentRow.Stage, currentRow.Status, currentRow.ControllingTrigger);

            cla(app.UtilizationBarAxes);
            bar(app.UtilizationBarAxes, categorical({'U_H','U_T','U_P'}), ...
                [currentRow.U_H, currentRow.U_T, currentRow.U_P]);
            hold(app.UtilizationBarAxes, 'on');
            yline(app.UtilizationBarAxes, 0.80, '--', 'Caution');
            yline(app.UtilizationBarAxes, 1.00, '--r', 'Critical');
            hold(app.UtilizationBarAxes, 'off');
            ylabel(app.UtilizationBarAxes, 'Utilization Ratio');
            title(app.UtilizationBarAxes, sprintf('Utilization -- Stage %d', currentRow.Stage));

            app.QCResultsTable.Data = app.QCResults;
        end

        %% ---------- Tab 7 callbacks + helpers ----------
        function updateStageSummaryPanel(app)
            deltas = computeStageDeltas(app.Telemetry, app.CurrentStage);
            if ~ismember(app.CurrentStage, app.QCResults.Stage)
                app.StageDataSummaryTextArea.Value = {sprintf(...
                    'Stage %d not yet run -- click "Run Stage" on the Telemetry Dashboard tab.', app.CurrentStage)};
                return
            end
            currentQC = app.QCResults(app.QCResults.Stage == app.CurrentStage, :);

            if app.CurrentStage == 1
                deltaText = 'No previous stage to compare (Stage 1 is the baseline).';
            else
                deltaText = sprintf(['Change vs previous stage: HL %+.0f kips | Torque %+.0f ft-lbf | ' ...
                    'SPP %+.0f psi | Qout %+.0f%% | ROP %+.0f ft/hr'], ...
                    deltas.dHL_kips, deltas.dTorque_ftlbf, deltas.dSPP_psi, deltas.dQout_pct, deltas.dROP_fthr);
            end

            app.StageDataSummaryTextArea.Value = {
                sprintf('Stage %d -- computed QC status: %s', app.CurrentStage, currentQC.Status)
                sprintf('Controlling trigger: %s', currentQC.ControllingTrigger)
                deltaText
                ''
                'This panel is a computed data aid only -- it does not answer the six questions for you.'
                };
        end

        function ConfirmRationaleButtonPushed(app, ~)
            q1 = strjoin(app.Q1TextArea.Value, ' ');
            q2 = strjoin(app.Q2TextArea.Value, ' ');
            q3 = strjoin(app.Q3TextArea.Value, ' ');
            q4 = strjoin(app.Q4TextArea.Value, ' ');
            q5 = strjoin(app.Q5TextArea.Value, ' ');
            q6 = strjoin(app.Q6TextArea.Value, ' ');

            newRow = buildStageRationale(app.CurrentStage, q1, q2, q3, q4, q5, q6);

            if ismember(app.CurrentStage, app.DecisionLog.Stage)
                app.DecisionLog(app.DecisionLog.Stage == app.CurrentStage, :) = newRow;
            else
                app.DecisionLog = [app.DecisionLog; newRow];
            end
            app.DecisionLogTable.Data = app.DecisionLog;

            if newRow.Confirmed
                uialert(app.UIFigure, sprintf('Stage %d rationale saved and complete. You may advance.', ...
                    app.CurrentStage), 'Rationale Saved', 'Icon', 'success');
            else
                uialert(app.UIFigure, sprintf(['Stage %d rationale saved but INCOMPLETE -- ' ...
                    'fill in all six fields before advancing.'], app.CurrentStage), ...
                    'Incomplete Rationale', 'Icon', 'warning');
            end
        end

        function NextStageButtonPushed(app, ~)
            [canGo, msg] = canAdvanceStage(app.DecisionLog, app.CurrentStage);
            if ~canGo
                uialert(app.UIFigure, msg, 'Cannot Advance');
                return
            end
            if app.CurrentStage >= height(app.Telemetry)
                uialert(app.UIFigure, 'Stage 9 is the final stage -- there is no next stage.', ...
                    'Final Stage', 'Icon', 'info');
                return
            end

            app.CurrentStage = app.CurrentStage + 1;
            app.Q1TextArea.Value = {''};
            app.Q2TextArea.Value = {''};
            app.Q3TextArea.Value = {''};
            app.Q4TextArea.Value = {''};
            app.Q5TextArea.Value = {''};
            app.Q6TextArea.Value = {''};
            updateStageIndicators(app);
            % Deliberately does NOT auto-run the new stage -- you must
            % click "Run Stage" on the Telemetry Dashboard tab to reveal
            % it. Keeping the reveal an explicit, visible action matters
            % for the video (Section G).
        end

        function updateStageIndicators(app)
            label = sprintf('Current Stage: %d of %d', app.CurrentStage, height(app.Telemetry));
            app.CurrentStageLabel.Text = label;
            app.Tab7CurrentStageLabel.Text = label;
            updateStageSummaryPanel(app);
        end

        %% ---------- Tab 9 callbacks ----------
        function ExportButtonPushed(app, ~)
            if isempty(app.Trajectory) || isempty(app.TDResults)
                uialert(app.UIFigure, 'Run Validate and Calculate (T&D) before exporting.', 'Nothing to Export');
                return
            end

            outDir = sprintf('PGG327_FinalExam_%d_Export', app.CaseDef.SerialNumber);
            if ~exist(outDir, 'dir')
                mkdir(outDir);
            end

            writetable(struct2table(app.CaseDef), fullfile(outDir, 'case_definition.csv'));
            writetable(app.Trajectory, fullfile(outDir, 'trajectory.csv'));
            writetable(app.TDResults, fullfile(outDir, 'torque_and_drag.csv'));
            writetable(app.Telemetry, fullfile(outDir, 'telemetry_personalized.csv'));
            writetable(app.QCResults, fullfile(outDir, 'qc_results.csv'));
            writetable(app.DecisionLog, fullfile(outDir, 'decision_log.csv'));

            exportLines = {
                sprintf('Exported to folder: %s', outDir)
                '  case_definition.csv'
                '  trajectory.csv'
                '  torque_and_drag.csv'
                '  telemetry_personalized.csv'
                '  qc_results.csv'
                '  decision_log.csv'
                };

            if ~isempty(app.SensitivityResults)
                r = app.SensitivityResults;
                sensTable = table(r.muList', r.pickup_kips', r.slackoff_kips', ...
                    r.drag_lb', r.torque_ftlbf', 'VariableNames', ...
                    {'mu','Pickup_kips','Slackoff_kips','Drag_lb','Torque_ftlbf'});
                writetable(sensTable, fullfile(outDir, 'sensitivity_results.csv'));
                exportLines{end+1} = '  sensitivity_results.csv';
            else
                exportLines{end+1} = '';
                exportLines{end+1} = 'NOTE: sensitivity_results.csv NOT included -- run Tab 8 (Sensitivity) first.';
            end

            app.ExportSummaryTextArea.Value = exportLines;
            uialert(app.UIFigure, sprintf('Export complete: %s', outDir), 'Export Successful', 'Icon', 'success');
        end

        function ResetButtonPushed(app, ~)
            app.SurveyRaw = [];
            app.SurveyValid = [];
            app.ValidationLog = initValidationLogTemplate();
            app.Trajectory = [];
            app.TDResults = [];
            app.QCResults = initQCResultsTemplate();
            app.DecisionLog = initDecisionLogTemplate();
            app.CurrentStage = 1;

            app.RawSurveyTable.Data = table();
            app.ValidationLogTextArea.Value = {''};
            app.CalculatedTrajectoryTable.Data = table();
            cla(app.Trajectory3DAxes);
            cla(app.DLSAxes);
            app.RegionSummaryLabel.Text = 'Regions identified: --';
            cla(app.PickupSlackoffAxes);
            cla(app.DragTorqueAxes);
            app.SurfaceValuesLabel.Text = 'Model surface values: --';
            cla(app.MechanicalTrendAxes);
            cla(app.OperationalTrendAxes);
            app.StatusLamp.Color = [0.5 0.5 0.5];
            app.ControllingTriggerLabel.Text = 'Status: --';
            cla(app.UtilizationBarAxes);
            app.QCResultsTable.Data = table();
            app.DecisionLogTable.Data = table();
            app.Q1TextArea.Value = {''};
            app.Q2TextArea.Value = {''};
            app.Q3TextArea.Value = {''};
            app.Q4TextArea.Value = {''};
            app.Q5TextArea.Value = {''};
            app.Q6TextArea.Value = {''};
            updateStageIndicators(app);
            app.ExportSummaryTextArea.Value = {'App reset. Re-run Upload/Validate/Calculate/Run Stage as needed.'};

            app.SensitivityResults = [];
            cla(app.PickupSlackoffMuAxes);
            cla(app.DragTorqueMuAxes);
            app.UncertaintyResultLabel.Text = 'Uncertainty case result: --';
            app.SensitivityResultsTable.Data = table();

            uialert(app.UIFigure, 'App state has been reset.', 'Reset Complete', 'Icon', 'info');
        end

        %% ---------- Tab 8 callback ----------
        function RunSensitivityButtonPushed(app, ~)
            if isempty(app.Trajectory)
                uialert(app.UIFigure, 'Validate the survey first (Tab: Survey & Validation).', 'No Trajectory');
                return
            end

            app.SensitivityResults = runFrictionSensitivity(app.BaseParams.muSensitivity, ...
                app.Trajectory, app.BaseParams.wAir_lbft, app.CaseDef.MW_ppg, ...
                app.BaseParams.rEff_ft, app.BaseParams.steelDensity_ppg);

            r = app.SensitivityResults;

            cla(app.PickupSlackoffMuAxes);
            hold(app.PickupSlackoffMuAxes, 'on');
            plot(app.PickupSlackoffMuAxes, r.muList, r.pickup_kips, '-o', 'DisplayName', 'Pickup');
            plot(app.PickupSlackoffMuAxes, r.muList, r.slackoff_kips, '-s', 'DisplayName', 'Slack-off');
            hold(app.PickupSlackoffMuAxes, 'off');
            legend(app.PickupSlackoffMuAxes, 'Location', 'best');
            grid(app.PickupSlackoffMuAxes, 'on');
            xlabel(app.PickupSlackoffMuAxes, 'Friction Factor (mu)');
            ylabel(app.PickupSlackoffMuAxes, 'Hook Load (kips)');
            title(app.PickupSlackoffMuAxes, 'Pickup / Slack-off vs Friction Factor');

            cla(app.DragTorqueMuAxes);
            yyaxis(app.DragTorqueMuAxes, 'left');
            plot(app.DragTorqueMuAxes, r.muList, r.drag_lb, '-o');
            ylabel(app.DragTorqueMuAxes, 'Drag (lb)');
            yyaxis(app.DragTorqueMuAxes, 'right');
            plot(app.DragTorqueMuAxes, r.muList, r.torque_ftlbf, '-s');
            ylabel(app.DragTorqueMuAxes, 'Torque (ft-lbf)');
            grid(app.DragTorqueMuAxes, 'on');
            xlabel(app.DragTorqueMuAxes, 'Friction Factor (mu)');
            title(app.DragTorqueMuAxes, 'Drag & Torque vs Friction Factor');

            app.SensitivityResultsTable.Data = table(r.muList', r.pickup_kips', r.slackoff_kips', ...
                r.drag_lb', r.torque_ftlbf', 'VariableNames', ...
                {'mu','Pickup_kips','Slackoff_kips','Drag_lb','Torque_ftlbf'});

            caseType = app.UncertaintyCaseDropDown.Value;
            uResult = runUncertaintyCase(caseType, app.Trajectory, app.BaseParams.wAir_lbft, ...
                app.CaseDef.MW_ppg, app.CaseDef.mu, app.BaseParams.rEff_ft, app.BaseParams.steelDensity_ppg);
            app.UncertaintyResultLabel.Text = sprintf(['Case "%s" -- Pickup: %.1f -> %.1f kips | ' ...
                'Slack-off: %.1f -> %.1f kips | Drag: %.0f -> %.0f lb | Torque: %.0f -> %.0f ft-lbf'], ...
                caseType, uResult.baseline.pickup_kips, uResult.modified.pickup_kips, ...
                uResult.baseline.slackoff_kips, uResult.modified.slackoff_kips, ...
                uResult.baseline.drag_lb, uResult.modified.drag_lb, ...
                uResult.baseline.torque_ftlbf, uResult.modified.torque_ftlbf);
        end

    end

    %% ============ Component creation ============
    methods (Access = private)

        function createComponents(app)
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1000 700];
            app.UIFigure.Name = 'PGG 327 Final Exam -- Drilling Decision-Support App';

            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 1000 700];

            createTab1_CaseDefinition(app);
            createTab2_SurveyValidation(app);
            createTab3_Wellpath(app);
            createTab4_TorqueDrag(app);
            createTab5_TelemetryDashboard(app);
            createTab6_QCDecision(app);
            createTab7_StageDecisionLog(app);
            createTab8_Sensitivity(app);
            createTab9_ExportAudit(app);

            app.UIFigure.Visible = 'on';
        end

        function createTab1_CaseDefinition(app)
            app.Tab1_CaseDefinition = uitab(app.TabGroup, 'Title', 'Case Definition');
            t = app.Tab1_CaseDefinition;

            app.SerialNumberEditFieldLabel = uilabel(t, 'Position', [20 630 160 22], ...
                'Text', 'Exam Serial Number (n):', 'FontWeight', 'bold');
            app.SerialNumberEditField = uieditfield(t, 'numeric', ...
                'Position', [190 630 100 22], 'Editable', 'off');
            app.MudWeightLabel = uilabel(t, 'Position', [20 590 600 22], 'Text', 'Personalized Mud Weight: -- ppg');
            app.FrictionFactorLabel = uilabel(t, 'Position', [20 560 600 22], 'Text', 'Personalized Friction Factor: --');
            app.HookLoadOffsetLabel = uilabel(t, 'Position', [20 530 600 22], 'Text', 'Hook-Load Telemetry Offset: -- kips');
            app.EquipmentLimitsLabel = uilabel(t, 'Position', [20 500 900 22], 'Text', 'Equipment Limits: --');
            app.AssumptionsTextAreaLabel = uilabel(t, 'Position', [20 460 300 22], ...
                'Text', 'Assumptions / Traceability Notes:', 'FontWeight', 'bold');
            app.AssumptionsTextArea = uitextarea(t, 'Position', [20 260 940 195], 'Editable', 'off');
        end

        function createTab2_SurveyValidation(app)
            app.Tab2_SurveyValidation = uitab(app.TabGroup, 'Title', 'Survey & Validation');
            t = app.Tab2_SurveyValidation;

            app.UploadDataButton = uibutton(t, 'push', 'Position', [20 630 130 30], 'Text', 'Upload Data', ...
                'ButtonPushedFcn', createCallbackFcn(app, @app.UploadDataButtonPushed, true));
            app.ValidateButton = uibutton(t, 'push', 'Position', [160 630 130 30], 'Text', 'Validate', ...
                'ButtonPushedFcn', createCallbackFcn(app, @app.ValidateButtonPushed, true));

            app.RawSurveyTableLabel = uilabel(t, 'Position', [20 595 200 20], 'Text', 'Raw Survey (MD / Inc / Az)', 'FontWeight', 'bold');
            app.RawSurveyTable = uitable(t, 'Position', [20 400 460 190]);

            app.ValidationLogLabel = uilabel(t, 'Position', [500 595 200 20], 'Text', 'Validation Log', 'FontWeight', 'bold');
            app.ValidationLogTextArea = uitextarea(t, 'Position', [500 400 460 190], 'Editable', 'off');

            app.CalculatedTrajectoryLabel = uilabel(t, 'Position', [20 375 300 20], ...
                'Text', 'Calculated Trajectory (Minimum Curvature)', 'FontWeight', 'bold');
            app.CalculatedTrajectoryTable = uitable(t, 'Position', [20 20 940 350]);
        end

        function createTab3_Wellpath(app)
            app.Tab3_Wellpath = uitab(app.TabGroup, 'Title', 'Wellpath');
            t = app.Tab3_Wellpath;

            app.Trajectory3DAxes = uiaxes(t, 'Position', [20 200 460 460]);
            app.DLSAxes = uiaxes(t, 'Position', [500 200 460 460]);
            app.RegionSummaryLabel = uilabel(t, 'Position', [20 160 940 30], ...
                'Text', 'Regions identified: --');
        end

        function createTab4_TorqueDrag(app)
            app.Tab4_TorqueDrag = uitab(app.TabGroup, 'Title', 'Torque & Drag');
            t = app.Tab4_TorqueDrag;

            app.CalculateButton = uibutton(t, 'push', 'Position', [20 630 150 30], 'Text', 'Calculate T&D', ...
                'ButtonPushedFcn', createCallbackFcn(app, @app.CalculateButtonPushed, true));

            app.PickupSlackoffAxes = uiaxes(t, 'Position', [20 200 460 410]);
            app.DragTorqueAxes = uiaxes(t, 'Position', [500 200 460 410]);
            app.SurfaceValuesLabel = uilabel(t, 'Position', [20 160 940 30], ...
                'Text', 'Model surface values: --');
        end

        function createTab5_TelemetryDashboard(app)
            app.Tab5_TelemetryDashboard = uitab(app.TabGroup, 'Title', 'Telemetry Dashboard');
            t = app.Tab5_TelemetryDashboard;

            app.CurrentStageLabel = uilabel(t, 'Position', [20 630 250 22], ...
                'Text', 'Current Stage: 1 of 9', 'FontWeight', 'bold');
            app.RunStageButton = uibutton(t, 'push', 'Position', [280 628 130 30], 'Text', 'Run Stage', ...
                'ButtonPushedFcn', createCallbackFcn(app, @app.RunStageButtonPushed, true));

            app.MechanicalTrendAxes = uiaxes(t, 'Position', [20 200 460 410]);
            app.OperationalTrendAxes = uiaxes(t, 'Position', [500 200 460 410]);
        end

        function createTab6_QCDecision(app)
            app.Tab6_QCDecision = uitab(app.TabGroup, 'Title', 'QC & Decision');
            t = app.Tab6_QCDecision;

            app.StatusLampLabel = uilabel(t, 'Position', [20 630 60 22], 'Text', 'Status:', 'FontWeight', 'bold');
            app.StatusLamp = uilamp(t, 'Position', [90 628 25 25], 'Color', [0.5 0.5 0.5]);
            app.ControllingTriggerLabel = uilabel(t, 'Position', [130 628 830 25], 'Text', 'Status: --');

            app.UtilizationBarAxes = uiaxes(t, 'Position', [20 260 460 350]);
            app.QCResultsTable = uitable(t, 'Position', [500 260 460 350]);
        end

        function createTab7_StageDecisionLog(app)
            app.Tab7_StageDecisionLog = uitab(app.TabGroup, 'Title', 'Stage Decision Log');
            t = app.Tab7_StageDecisionLog;

            app.Tab7CurrentStageLabel = uilabel(t, 'Position', [20 660 250 22], ...
                'Text', 'Current Stage: 1 of 9', 'FontWeight', 'bold');
            app.StageDataSummaryTextArea = uitextarea(t, 'Position', [280 610 690 70], 'Editable', 'off');

            qLabels = {'Q1: What changed?', 'Q2: Which calculation/measurement controls the risk?', ...
                'Q3: What status do you assign, and why?', 'Q4: What uncertainty remains?', ...
                'Q5: What action/escalation do you recommend?', 'Q6: What evidence do you require next?'};
            yTop = 590;
            rowH = 55;
            for k = 1:6
                yPos = yTop - (k-1)*rowH;
                lbl = uilabel(t, 'Position', [20 yPos 940 18], 'Text', qLabels{k}, 'FontWeight', 'bold');
                ta = uitextarea(t, 'Position', [20 yPos-32 940 30]);
                switch k
                    case 1, app.Q1Label = lbl; app.Q1TextArea = ta;
                    case 2, app.Q2Label = lbl; app.Q2TextArea = ta;
                    case 3, app.Q3Label = lbl; app.Q3TextArea = ta;
                    case 4, app.Q4Label = lbl; app.Q4TextArea = ta;
                    case 5, app.Q5Label = lbl; app.Q5TextArea = ta;
                    case 6, app.Q6Label = lbl; app.Q6TextArea = ta;
                end
            end

            app.ConfirmRationaleButton = uibutton(t, 'push', 'Position', [20 30 160 30], ...
                'Text', 'Confirm Rationale', ...
                'ButtonPushedFcn', createCallbackFcn(app, @app.ConfirmRationaleButtonPushed, true));
            app.NextStageButton = uibutton(t, 'push', 'Position', [200 30 130 30], 'Text', 'Next Stage', ...
                'ButtonPushedFcn', createCallbackFcn(app, @app.NextStageButtonPushed, true));

            app.DecisionLogTable = uitable(t, 'Position', [20 70 940 175]);
        end

        function createTab8_Sensitivity(app)
            app.Tab8_Sensitivity = uitab(app.TabGroup, 'Title', 'Sensitivity');
            t = app.Tab8_Sensitivity;

            app.RunSensitivityButton = uibutton(t, 'push', 'Position', [20 630 150 30], ...
                'Text', 'Run Sensitivity', ...
                'ButtonPushedFcn', createCallbackFcn(app, @app.RunSensitivityButtonPushed, true));

            app.UncertaintyCaseDropDown = uidropdown(t, 'Position', [190 630 220 30], ...
                'Items', {'+5% string weight', 'Mud weight +0.5ppg'}, ...
                'Value', '+5% string weight');

            app.PickupSlackoffMuAxes = uiaxes(t, 'Position', [20 260 460 350]);
            app.DragTorqueMuAxes = uiaxes(t, 'Position', [500 260 460 350]);

            app.UncertaintyResultLabel = uilabel(t, 'Position', [20 220 940 30], ...
                'Text', 'Uncertainty case result: --');
            app.SensitivityResultsTable = uitable(t, 'Position', [20 20 940 190]);
        end

        function createTab9_ExportAudit(app)
            app.Tab9_ExportAudit = uitab(app.TabGroup, 'Title', 'Export & Audit');
            t = app.Tab9_ExportAudit;

            app.ExportButton = uibutton(t, 'push', 'Position', [20 630 130 30], 'Text', 'Export', ...
                'ButtonPushedFcn', createCallbackFcn(app, @app.ExportButtonPushed, true));
            app.ResetButton = uibutton(t, 'push', 'Position', [160 630 130 30], 'Text', 'Reset', ...
                'ButtonPushedFcn', createCallbackFcn(app, @app.ResetButtonPushed, true));

            app.ExportSummaryTextArea = uitextarea(t, 'Position', [20 300 940 310], 'Editable', 'off', ...
                'Value', {'Nothing exported yet.'});
        end

    end

    %% ============ App creation / deletion ============
    methods (Access = public)

        function app = PGG327FinalExam
            createComponents(app)
            registerApp(app, app.UIFigure)
            runStartupFcn(app, @startupFcn)
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end

    end
end
