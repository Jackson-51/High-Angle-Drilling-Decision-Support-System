function exportFullReport(app, QCResults, DecisionLog, CaseDef, CurrentStage)
%EXPORTFULLREPORT Export the complete examination record.
%
%   The workbook contains:
%       1. Case Definition
%       2. QC Results
%       3. Decision Log
%       4. Audit Summary
%
%   Application private properties are passed into this function
%   explicitly by the App Designer callback.

    % ============================================================
    % ASK USER WHERE TO SAVE
    % ============================================================

    [file, path] = uiputfile( ...
        {'*.xlsx', 'Excel Workbook (*.xlsx)'}, ...
        'Export Full Examination Report');

    if isequal(file, 0)
        return
    end

    filename = fullfile(path, file);


    % ============================================================
    % EXPORT EVERYTHING
    % ============================================================

    try

        % --------------------------------------------------------
        % QC RESULTS
        % --------------------------------------------------------

        if isempty(QCResults)

            qcTable = table();

        else

            qcTable = QCResults;

        end


        % --------------------------------------------------------
        % DECISION LOG
        % --------------------------------------------------------

        if isempty(DecisionLog)

            decisionTable = table();

        else

            decisionTable = DecisionLog;

        end


        % --------------------------------------------------------
        % AUDIT SUMMARY
        % --------------------------------------------------------

        if isempty(QCResults) && isempty(DecisionLog)

            auditTable = table();

        else

            % Refresh audit display using explicitly supplied data
            updateAuditDisplay( ...
                app, ...
                QCResults, ...
                DecisionLog, ...
                CurrentStage);

            auditTable = app.AuditResultsTable.Data;

        end


        % --------------------------------------------------------
        % WRITE QC RESULTS
        % --------------------------------------------------------

        if ~isempty(qcTable)

            writetable( ...
                qcTable, ...
                filename, ...
                'Sheet', 'QC Results');

        end


        % --------------------------------------------------------
        % WRITE DECISION LOG
        % --------------------------------------------------------

        if ~isempty(decisionTable)

            writetable( ...
                decisionTable, ...
                filename, ...
                'Sheet', 'Decision Log');

        end


        % --------------------------------------------------------
        % WRITE AUDIT SUMMARY
        % --------------------------------------------------------

        if ~isempty(auditTable)

            writetable( ...
                auditTable, ...
                filename, ...
                'Sheet', 'Audit Summary');

        end


        % ========================================================
        % EXPORT CASE DEFINITION
        % ========================================================

        caseNames = { ...
            'Student Serial Number'
            'Mud Weight (ppg)'
            'Friction Factor'
            'Hook Load Offset (kips)'
            'Hook Load Limit (kips)'
            'Torque Limit (ft-lbf)'
            'SPP Limit (psi)'};


        caseValues = [ ...
            CaseDef.SerialNumber
            CaseDef.MW_ppg
            CaseDef.mu
            CaseDef.HLOffset_kips
            CaseDef.HLlimit_kips
            CaseDef.Tlimit_ftlbf
            CaseDef.SPPlimit_psi];


        caseTable = table( ...
            string(caseNames), ...
            caseValues, ...
            'VariableNames', ...
            {'Parameter','Value'});


        writetable( ...
            caseTable, ...
            filename, ...
            'Sheet', 'Case Definition');


        % ========================================================
        % SUCCESS MESSAGE
        % ========================================================

        uialert(app.UIFigure, ...
            sprintf([ ...
                'Full examination report exported successfully.\n\n' ...
                'File:\n%s'], ...
                filename), ...
            'Export Complete');


    catch ME

        uialert(app.UIFigure, ...
            sprintf([ ...
                'Could not export the full examination report.\n\n' ...
                '%s'], ...
                ME.message), ...
            'Export Error');

    end

end