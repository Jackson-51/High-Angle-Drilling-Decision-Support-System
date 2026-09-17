function exportQCResults(app, QCResults)
%EXPORTQCRESULTS Export all QC results generated so far.

    % ============================================================
    % CHECK DATA
    % ============================================================

    if isempty(QCResults)

        uialert(app.UIFigure, ...
            'There are no QC results to export.', ...
            'No QC Data');

        return
    end


    % ============================================================
    % ASK USER WHERE TO SAVE
    % ============================================================

    [file, path] = uiputfile( ...
        {'*.xlsx', 'Excel Workbook (*.xlsx)'; ...
         '*.csv',  'CSV File (*.csv)'}, ...
        'Export QC Results');

    if isequal(file,0)

        return

    end


    filename = fullfile(path,file);


    % ============================================================
    % EXPORT
    % ============================================================

    try

        writetable(QCResults, filename);

        uialert(app.UIFigure, ...
            sprintf('QC results exported successfully:\n\n%s', ...
            filename), ...
            'Export Complete');

    catch ME

        uialert(app.UIFigure, ...
            sprintf('Could not export QC results.\n\n%s', ...
            ME.message), ...
            'Export Error');

    end

end