function convertElec2MNI(myDataPath,filename)

% Get standardized electrodes through surface based registration or linear
% convert electrodes from patient's individual MRI to MNI305 space

% Freesurfer subjects directory
FSsubjectsdir = myDataPath.freesurfer;
origsubjectsdir = extractBefore(myDataPath.freesurfer,'/derivatives');

subjname_temp = extractBetween(filename,'/sub-','/ses-');
subjname = ['sub-' subjname_temp{1}];

sesname_temp = extractBetween(filename,'/ses-','/ieeg');
sesname = ['ses-' sesname_temp{1}];

% subject freesurfer dir
FSdir = fullfile(FSsubjectsdir,subjname,sesname,...
    [subjname,'_',sesname,'_T1w']);

% get electrodes info
% ATTENTION: do not convert to MNI space more than once, because it will
% change the electrode positions again! Therefore, use the original
% electrode positions from the original electrodes.tsv
origelecfilename = fullfile(origsubjectsdir,subjname,sesname,'ieeg',...
    [subjname, '_', sesname, '_electrodes.tsv']);
elecs_tsv_share = readtable(filename,'FileType','text','Delimiter','\t');
elecs_tsv_orig = readtable(origelecfilename,'FileType','text','Delimiter','\t');
if iscell(elecs_tsv_orig.x)
    elecmatrix = NaN(size(elecs_tsv_orig,1),3);
    for ll = 1:size(elecs_tsv_orig,1)
        if ~isequal(elecs_tsv_orig.x{ll},'n/a')
            elecmatrix(ll,:) = [str2double(elecs_tsv_orig.x{ll}) str2double(elecs_tsv_orig.y{ll}) str2double(elecs_tsv_orig.z{ll})];
        end
    end
else
    elecmatrix = [elecs_tsv_orig.x elecs_tsv_orig.y elecs_tsv_orig.z];
end

% get hemisphere for each electrode
hemi = elecs_tsv_share.hemisphere;

% convert to MNI using surface
mni_coords = mni305ThroughFsSphere(elecmatrix,hemi,FSdir,FSsubjectsdir);

% convert to MNI using linear transformations
% mni_coords = mni305linear(elecmatrix,FSdir);

% replace patient's individual electrode positions with MNI space
elecs_tsv_share.x = mni_coords(:,1);
elecs_tsv_share.y = mni_coords(:,2);
elecs_tsv_share.z = mni_coords(:,3);

elecs_tsv_share = bids_tsv_nan2na(elecs_tsv_share);

writetable(elecs_tsv_share, filename, 'Delimiter', 'tab', 'FileType', 'text');

end
