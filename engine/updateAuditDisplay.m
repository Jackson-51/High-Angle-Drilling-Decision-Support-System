function updateAuditDisplay(app, QCResults, DecisionLog, CurrentStage)
%UPDATEAUDITDISPLAY Refresh the final audit display.
%
% Builds a stage-by-stage audit summary from the QC results and
% decision log supplied by the application.
%
% This function does not perform new QC calculations.

    % ============================================================
    % CHECK WHETHER ANY AUDIT DATA EXISTS
    % ============================================================

    if isempty(QCResults) && isempty(DecisionLog)

        app.AuditResultsTable.Data = table();

        app.AuditResultsTable.ColumnName = { ...
            'Stage', ...
            'QC Status', ...
            'Maximum Utilization', ...
            'Controlling Trigger', ...
            'Decision Confirmed'};

        app.AuditStatusLabel.Text = ...
            'Audit Status: NO STAGES COMPLETED';

        return
    end


    % ============================================================
    % DETERMINE NUMBER OF STAGES TO SHOW
    % ============================================================

    qcStages = [];
    decisionStages = [];

    if ~isempty(QCResults)
        qcStages = QCResults.Stage;
    end

    if ~isempty(DecisionLog)
        decisionStages = DecisionLog.Stage;
    end

    allStages = unique([qcStages; decisionStages]);


    % ============================================================
    % PREPARE AUDIT TABLE
    % ============================================================

    n = numel(allStages);

    AuditStage = zeros(n,1);
    QCStatus = strings(n,1);
    MaximumUtilization = NaN(n,1);
    ControllingTrigger = strings(n,1);
    DecisionConfirmed = false(n,1);


    % ============================================================
    % BUILD ONE AUDIT ROW PER STAGE
    % ============================================================

    for i = 1:n

        stage = allStages(i);

        AuditStage(i) = stage;


        % --------------------------------------------------------
        % QC INFORMATION
        % --------------------------------------------------------

        if ~isempty(QCResults)

            qcRow = QCResults.Stage == stage;

            if any(qcRow)

                qc = QCResults(qcRow, :);

                QCStatus(i) = qc.Status;
                MaximumUtilization(i) = qc.Umax;
                ControllingTrigger(i) = qc.ControllingTrigger;

            else

                QCStatus(i) = "NOT RUN";
                ControllingTrigger(i) = "—";

            end

        else

            QCStatus(i) = "NOT RUN";
            ControllingTrigger(i) = "—";

        end


        % --------------------------------------------------------
        % DECISION INFORMATION
        % --------------------------------------------------------

        if ~isempty(DecisionLog)

            decisionRow = DecisionLog.Stage == stage;

            if any(decisionRow)

                DecisionConfirmed(i) = ...
                    DecisionLog.Confirmed(decisionRow);

            end

        end

    end


    % ============================================================
    % CREATE AUDIT TABLE
    % ============================================================

    auditTable = table( ...
        AuditStage, ...
        QCStatus, ...
        MaximumUtilization, ...
        ControllingTrigger, ...
        DecisionConfirmed, ...
        'VariableNames', { ...
            'Stage', ...
            'QCStatus', ...
            'MaximumUtilization', ...
            'ControllingTrigger', ...
            'DecisionConfirmed'});


    % ============================================================
    % DISPLAY AUDIT TABLE
    % ============================================================

    app.AuditResultsTable.Data = auditTable;

    app.AuditResultsTable.ColumnName = { ...
        'Stage', ...
        'QC Status', ...
        'Maximum Utilization', ...
        'Controlling Trigger', ...
        'Decision Confirmed'};


    % ============================================================
    % UPDATE AUDIT STATUS
    % ============================================================

    completedQC = false(n,1);
    confirmedDecisions = false(n,1);

    if ~isempty(QCResults)

        completedQC = ismember( ...
            allStages, ...
            QCResults.Stage);

    end

    if ~isempty(DecisionLog)

        confirmedDecisions = ...
            ismember( ...
                allStages, ...
                DecisionLog.Stage(DecisionLog.Confirmed));

    end


    % ============================================================
    % DETERMINE OVERALL AUDIT STATUS
    % ============================================================

    if CurrentStage >= 9

        if all(completedQC) && all(confirmedDecisions)

            app.AuditStatusLabel.Text = ...
                'Audit Status: COMPLETE';

        else

            app.AuditStatusLabel.Text = ...
                'Audit Status: STAGE 9 REACHED — REVIEW REQUIRED';

        end

    else

        app.AuditStatusLabel.Text = sprintf( ...
            'Audit Status: IN PROGRESS — CURRENT STAGE %d OF 9', ...
            CurrentStage);

    end

end