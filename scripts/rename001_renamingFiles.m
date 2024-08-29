%% renaming files
% author: Dorien van Blooijs
% date: May 2021

% first, several OPTIONS are programmed to: 
% 1. change participants.tsv to contain only the participants that are
%    present in the specific folder for sharing
% 2. change scans.tsv to contain only the eeg-files that are present in the
%    specific folder for sharing
% 3. change datasetDecriptor manually
% 4. convert electrode positions to MNI space (general brain). This is
%    required for sharing data in publicly available datasets.
% 5. change content of specific files (for example, not sharing SOZ in
%    electrodes.tsv)

% REQUIRED
% at the end of the script, the actual renaming of files is programmed

%% set paths
clear
close all
clc

% add current path from folder which contains this script
rootPath = matlab.desktop.editor.getActiveFilename;
RepoPath = fileparts(rootPath);
matlabFolder = strfind(RepoPath,'matlab');
addpath(genpath(RepoPath(1:matlabFolder+6)));

[myDataPath, cfg] = rename_setLocalDataPath(1);

% housekeeping 
clear rootPath RepoPath matlabFolder

%% load key for renaming:
% this file should be named key.xlsx, and in the first column, it should
% contain the original name, in the second column, it should contain the
% name that should replace the original name

dirName = myDataPath.shareFolder;
key = readcell(fullfile(dirName,'key.xlsx'));

%% get all files in a specific directory

fileList = getAllFiles(dirName);

%% 1. OPTIONAL: change content of participants.tsv to contain only the participants in this specific folder for sharing

idx_particip_tsv = contains(fileList,'participants.tsv');
particip_tsv = readtable(fileList{idx_particip_tsv},'FileType','text','Delimiter','\t');

folderContent = dir(myDataPath.shareFolder);
idx_particip = contains({folderContent(:).name},'sub-');
particip = {folderContent(idx_particip).name};

keep = [];
for ii = 1:size(particip_tsv,1)
    if sum(contains(particip,particip_tsv.participant_id{ii})) == 1
        % maybe not all sessions are included for this specific patient, so
        % look into the sessions to make sure only the session of a
        % participant that is included in this folder is mentioned in
        % participants.tsv
        subContent = dir(fullfile(myDataPath.shareFolder,particip_tsv.participant_id{ii}));
        idx_ses = contains({subContent(:).name},'ses-');
        ses = {subContent(idx_ses).name};

        if sum(contains(ses,particip_tsv.session(ii))) == 1
            keep = [keep, ii]; %#ok<AGROW> 
        end
    else

    end
end

del = setdiff(1:size(particip_tsv,1),keep);
particip_tsv(del,:) = [];
writetable(particip_tsv, fileList{idx_particip_tsv}, 'Delimiter', 'tab', 'FileType', 'text');% save file

% housekeeping
clear del folderContent idx_particip idx_particip_tsv idx_ses ii keep particip particip_tsv ses subContent

%% 2. OPTIONAL: change content of scans.tsv if not all scans are going to be shared

% find all scans.tsv files
idx_scans_tsv = find(contains(fileList,'scans.tsv')==1);
for ii = 1: size(idx_scans_tsv,1) % for each scans.tsv file

    % read scans.tsv
    scans_tsv = readtable(fileList{idx_scans_tsv(ii)},'FileType','text','Delimiter','\t');

    % find the eeg-files for each specific subject
    folder = fileparts(fileList{idx_scans_tsv(ii)});
    folderContent = dir(fullfile(folder,'ieeg'));
    idx_scans = contains({folderContent(:).name},'.eeg');
    scans = {folderContent(idx_scans).name};

    % keep only the mentioned eegs in scans.tsv if present in folder to be
    % shared
    keep = [];
    for jj = 1:size(scans_tsv,1)
        filename = extractAfter(scans_tsv.filename{jj},'ieeg/');
        if sum(contains(scans,filename)) == 1
            keep = [keep, jj]; %#ok<AGROW>
        else
            % do nothing, these should be removed
        end
    end

    % delete the mentioned eegs in scans.tsv if not present in folder to be
    % shared, and save scans.tsv
    del = setdiff(1:size(scans_tsv,1),keep);
    scans_tsv(del,:) = [];
    writetable(scans_tsv, fileList{idx_scans_tsv(ii)}, 'Delimiter', 'tab', 'FileType', 'text');% save file
end

% housekeeping
clear del filename folder folderContent idx_scans idx_scans_tsv ii jj keep scans scans_tsv 

%% 3. OPTIONAL: rename datasetDescriptor

idx_dataDesc = contains(fileList,'dataset_description');
dataDesc = read_json(fileList{idx_dataDesc});

% change fields manually

% save dataDesc again
write_json(fileList{idx_dataDesc}, dataDesc);

% housekeeping
clear dataDesc idx_dataDesc

%% 4. OPTIONAL: change electrode positions in electrodes.tsv to MNI space (instead of positions on the individual brain)
% THIS IS REQUIRED FOR SHARING DATA IN PUBLICLY AVAILABLE DATASETS!!!

idx = contains(fileList,'electrodes.tsv')==0;

fileList_elec = fileList;
fileList_elec(idx) = [];

for subj = 1:size(fileList_elec,1)

    convertElec2MNI(myDataPath,fileList_elec{subj});

end

disp('Conversion to MNI space is completed.')

% housekeeping
clear fileList_elec idx subj

%% 5. OPTIONAL: change content of specific files (uses cfg.reqFields defined in personalDataPath.m)
reduceFiles = input('Do you want to reduce the variables in some specific files, and did you specify this in personalDataPath.m? [y/n]: ','s');

if strcmp(reduceFiles,'y')
    % get all files
    fileList = getAllFiles(dirName);

    % change what specific files should contain

    for jj = 1:size(cfg,2)

        if ~isempty(cfg(jj).reqFields)
            for ii = 1:size(fileList,1)
                clear Variable newVariable Variable_tsv

                if contains(fileList{ii},cfg(jj).filename{1})

                    [~,~,fileExt] = fileparts(fileList{ii});

                    if strcmp(fileExt,'.tsv')
                        % load file
                        Variable = readtable(fileList{ii},'FileType','text','Delimiter','\t');

                        % add all columns that are required
                        for k = 1:size(cfg(jj).reqFields,2)
                            if any(contains(fieldnames(Variable),cfg(jj).reqFields{k}))
                            newVariable.(cfg(jj).reqFields{k}) = Variable.(cfg(jj).reqFields{k});
                            end
                        end

                        % make struct into table
                        Variable_tsv = struct2table(newVariable);

                        bids_tsv_nan2na(Variable_tsv);

                        % save table
                        writetable(Variable_tsv, fileList{ii}, 'Delimiter', 'tab', 'FileType', 'text');

                    elseif strcmp(fileExt,'.mat')
                        % load file
                        Variable = load(fileList{ii});

                        % add all columns that are required
                        for k = 1:size(cfg(jj).reqFields,2)
                            newVariable.(cfg(jj).reqFields{k}) = Variable.(cfg(jj).reqFields{k});
                        end

                        % save mat-file
                        save(fileList{ii},'-struct','newVariable')
                    
                    elseif strcmp(fileExt,'.json')
                        Variable = read_json(fileList{ii});

                        % add all columns that are required
                        for k = 1:size(cfg(jj).reqFields,2)
                            newVariable.(cfg(jj).reqFields{k}) = Variable.(cfg(jj).reqFields{k});
                        end

                        write_json(fileList{ii},newVariable)
                    else
                        warning('For this file %s, no code has been written yet',fileList{ii})

                    end
                end
            end
        end
    end
end

% housekeeping
clear reduceFiles jj ii k fileExt Variable newVariable Variable_tsv 

%% ESSENTIAL: rename variables containing the name and move them to new named directory

% Make sure the user wants to annonimize TRC files when they are in the
% fileList. In principle only BIDS-format files are shared.
checkTRC = 0;
if any(contains(fileList,'.TRC'))
    replyTRC = input('NOTE: Only BIDS-format files should be shared. \nAre you sure you want to rename .TRC files? [y/n]: ','s');
    if strcmpi(replyTRC,'y')
        checkTRC =  1;
    end
end

% remove the key.xlsx from the fileList to be converted
idx = contains(fileList,'key');
fileList(idx) = [];

% run through all files
for ii = 1:size(fileList,1)
    foundKey = 0;

    % run through all keys to find matching key
    for jj = 1:size(key,1)

        if contains(fileList(ii),key(jj,1))
            foundKey = 1; % in case there is a matching key

            % rename variables in the file
            indivkey = key(jj,1); 
            renamekey = key(jj,2);
            break
        end
    end

    % if there is a matching key
    if foundKey == 1
        [nameDir, nameFile, nameExt] = fileparts(fileList{ii});

        % rename VARIABLES and VARIABLE CONTENT
        renameFileContent(fileList{ii},indivkey,renamekey,checkTRC)

        % rename FILENAME and move file to new location
        if any(strcmp(nameExt,{'.vhdr','.vmrk','.eeg'}))
            % do not copy because it is already written by
            % renameFileContent!
        else
            newname = replace(fileList{ii},indivkey{:},renamekey{:});
            [newnameDir,newnameFile,newnameExt] = fileparts(newname);

            % make directory if it does not exist yet
            if ~exist(newnameDir,'dir')
                mkdir(newnameDir)
            end

            %             movefile(fileList{i},newname)
            copyfile(fileList{ii},newname)
            fprintf('Moved file to %s \n',newname)
        end

        % if directory is empty, delete directory
        if isempty(getAllFiles(nameDir))
            rmdir(nameDir)
        end

    elseif foundKey == 0 % there is no original patient name in the 
            % filename, but we need to check whether there are no patient 
            % names within the file (for example in scans.tsv)
        
            % run through all keys to find whether this file has already
            % been renamed (for example in an earlier attempt)
            [nameDir, nameFile, nameExt] = fileparts(fileList{ii});
            foundnewKey = 0;
            for jj = 1:size(key,1)
                if contains(nameFile,key(jj,2))
                    foundnewKey = 1; % in case there is a matching key

                    break
                end
            end

            if foundnewKey == 0 % if there is no recoded patient name in 
                % the filename, we need to check whether there are no 
                % patient names within the file

                origkey = key(:,1);
                newkey = key(:,2);

                renameFileContent(fileList{ii},origkey,newkey,checkTRC)
            end
    end
end

%% END OF SCRIPT