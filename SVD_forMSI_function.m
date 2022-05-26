% SVD_forMSI_function.m
% Sarah West 
% 9/6/21

% Runs SVD as a function with mouse number as an input

% Runs SVD on all the data from a given animal. Must be done with MSI or everything will die.
% For each mouse, loads the filtered and blood vessel regressed data, concatenates it all
% together, runs SVD, then saves the outputs.

function []=SVD_forMSI_function(mouse_number)
    
    % Convert mouse number to a string 
    mouse=num2str(mouse_number); 
    
    n_compressions=200;

    folder=pwd;
    addpath(genpath(folder));
    dir_in=[folder '/preprocessed round 5/']; % directory on the MSI network. 
    dir_out=[folder '/' ]; % directory on the MSI network.
    
    % Load the list of days included for each mouse.
    load([folder '/days_all.mat']); 

    % Determine index of mouse within days_all.
    mousei=find(any(days_all(:).mouse== mouse));
    
    disp(['mouse ' mouse]);

    % Make output filename
    filename_output=[dir_out 'm' mouse '_SVD_compressed.mat']; 

    % Start a running count of how many stacks each mouse has; for data space pre-alotment
    total_stacks=0;
    
    % For each  day; count how many stacks are in each day and add them all up so you can make an accurately sized matrix for data pre-alotment
    for dayi=1:size(days_all(mousei).days,2)  
        
        % Get the day name.
        day=days_all(mousei).days(dayi).name; 
        
        % List the stacks in a given day
        stacks=dir([dir_in day '/data*.mat']);  
        
        % Add the number of stacks to the running count
        total_stacks=total_stacks+size(stacks,1); 
    end 
    disp(['total stacks =' num2str(total_stacks)]); 
    all_data=NaN(total_stacks*6000, 256*256);  % initialize data matrix

    % load and concatenate data
    disp('concatenating');
    count=0;
    try
        % For each  day; 
        for dayi=1:size(days_all(mousei).days,2)  
        
            % Get the day name.
            day=days_all(mousei).days(dayi).name; 
            
            % List the  stacks in a given day
            stacks=dir([dir_in day '/data*.mat']);  
            for stacki=1:size(stacks,1) % for each stack
                load([dir_in day '/' stacks(stacki).name]);  
                data_reshaped=reshape(data,256*256, 6000); 
                all_data((count*6000)+1:(count+1)*6000, :)=data_reshaped';
                count=count+1;
            end 
        end
    % run SVD   
    disp('running SVD'); 
    [U,S,V]=compute_svd(all_data, 'randomized', n_compressions);
    disp('saving'); 
    save(filename_output, 'U', 'S', 'V', '-v7.3'); 
    catch
        disp('found a corrupt file');
    end

end
