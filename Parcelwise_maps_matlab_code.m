%Parcelwise probability maps
%Required:
%Lesion Quantification ToolkitSPM12

clc
clear all
 
% Add paths to support tools and core functions
addpath('/Users/sam/Documents/MATLAB/Lesion_Quantification_Toolkit/Functions');
addpath(genpath('/Users/sam/Documents/MATLAB/Lesion_Quantification_Toolkit/Support_Tools'));
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set up cfg structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%% Assign relevant paths %%%%%%
 
% Path to output directory (patient and atlas result directories will be created within the output directory)
cfg.out_path = '/Users/sam/LQT_results';
% Path to lesion (pre-registered to MNI template)
cfg.lesion_path = '/Users/sam/LQT_lesions';
% Path to parcellation (should have identical dimensions to lesion and be in MNI template space)
cfg.parcel_path = '/Users/sam/LQT_atlas/32bitsBN_Atlas_246_1mm.nii';
 
%%%%% Output Filename Options %%%%%%
% Patient ID (used as prefix for output files)
cfg.pat_id = []; % could be a list, but in this example it is being taken from the file names selected later
% File suffix -- used as suffix for output files. Atlas name is recommended (e.g. AAL, Power, Gordon, etc.).
cfg.file_suffix = 'BNT';
 
%%%%%% Navigate to directory containing lesion files %%%%%%
lesion_dir = cfg.lesion_path;
cd(lesion_dir);
lesion_files = dir('*.nii');
% Loop through lesion files and create measures
for i = 1:length(lesion_files)
    % Get patient lesion file and patient ID
    cfg.lesion_path = fullfile(lesion_dir, lesion_files(i).name); % set lesion path to the current lesion
    cfg.pat_id = lesion_files(i).name; % extract just the patient ID portion of the filename
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Create Damage and Disconnection Measures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get parcel damage for patient
    util_get_parcel_damage(cfg);
end
% navigate to output directory
cd(cfg.out_path);
