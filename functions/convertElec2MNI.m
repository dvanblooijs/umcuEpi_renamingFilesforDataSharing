function convertElec2MNI(myDataPath,filename,key)

% Get standardized electrodes through surface based registration or linear
% convert electrodes from patient's individual MRI to MNI305 space

% Freesurfer subjects directory
FSsubjectsdir = myDataPath.freesurfer;

subjname_temp = extractBetween(filename,'/sub-','/ses-');
subjname = ['sub-' subjname_temp{1}];

sesname_temp = extractBetween(filename,'/ses-','/ieeg');
sesname = ['ses-' sesname_temp{1}];

indivkey = contains(key(:,2),subjname);
origsubjname = key{indivkey,1};

% subject freesurfer dir
FSdir = fullfile(FSsubjectsdir,origsubjname,sesname,...
    [origsubjname,'_',sesname,'_T1w']);

% get electrodes info
elecs_tsv = readtable(filename,'FileType','text','Delimiter','\t');
if iscell(elecs_tsv.x)
    elecmatrix = NaN(size(elecs_tsv,1),3);
    for ll = 1:size(elecs_tsv,1)
        if ~isequal(elecs_tsv.x{ll},'n/a')
            elecmatrix(ll,:) = [str2double(elecs_tsv.x{ll}) str2double(elecs_tsv.y{ll}) str2double(elecs_tsv.z{ll})];
        end
    end
else
    elecmatrix = [elecs_tsv.x elecs_tsv.y elecs_tsv.z];
end

% get hemisphere for each electrode
hemi = elecs_tsv.hemisphere;

% convert to MNI using surface
mni_coords = mni305ThroughFsSphere(elecmatrix,hemi,FSdir,FSsubjectsdir);

% convert to MNI using linear transformations
% mni_coords = mni305linear(elecmatrix,FSdir);

% replace patient's individual electrode positions with MNI space
elecs_tsv.x = mni_coords(:,1);
elecs_tsv.y = mni_coords(:,2);
elecs_tsv.z = mni_coords(:,3);

elecs_tsv = bids_tsv_nan2na(elecs_tsv);

writetable(elecs_tsv, filename, 'Delimiter', 'tab', 'FileType', 'text');

end
