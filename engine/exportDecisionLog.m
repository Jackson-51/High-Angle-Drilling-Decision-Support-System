function exportDecisionLog(app, DecisionLog)
%EXPORTDECISIONLOG Export the stage decision-rationale log.

    % ============================================================
    % CHECK DATA
    % ============================================================

    if isempty(DecisionLog)

        uialert(app.UIFigure, ...
            'There are no decision records to export.', ...
            'No Decision Data');

        return
    end


    % ============================================================
    % ASK USER WHERE TO SAVE
    % ============================================================

    [file, path] = uiputfile( ...
        {'*.xlsx', 'Excel Workbook (*.xlsx)'; ...
         '*.csv',  'CSV File (*.csv)'}, ...
        'Export Decision Log');

    if isequal(file,0)

        return

    end


    filename = fullfile(path,file);


    % ============================================================
    % EXPORT
    % ============================================================

    try

        [~,~,ext] = fileparts(filename);

        if strcmpi(ext,'.xlsx')

            writetable(DecisionLog, filename);

        elseif strcmpi(ext,'.csv')

            writetable(DecisionLog, filename);

        else

            error('Unsupported file type.');

        end


        uialert(app.UIFigure, ...
            sprintf('Decision log exported successfully:\n\n%s', ...
            filename), ...
            'Export Complete');

    catch ME

        uialert(app.UIFigure, ...
            sprintf('Could not export decision log.\n\n%s', ...
            ME.message), ...
            'Export Error');

    end

end