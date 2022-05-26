% create_RandomSubset_mice_all.m
% Sarah West
% 2/22/22

% Takes mice_all and gets a list of a subset of stacks distributed across
% all days per mouse, randomly chosen within days. Is so you don't have to
% use as much resources for SVD compression on MSI.

% Parameters for directories
clear all;

experiment_name='Random Motorized Treadmill';
dir_base='Y:\Sarah\Analysis\Experiments\';
dir_exper=[dir_base experiment_name '\']; 
dir_out=dir_exper; 
mkdir(dir_out);

% Load mice_all
load([dir_exper 'mice_all.mat']);

% Adjust here if you want to use only some mice.
mice_all = mice_all(1:3);

% Paramters for randomizing--Fields you want representation from, and amount of stacks you want (per
% mouse) represented from each.
fields = {'stacks', 48 ;
           'spontaneous', 24};

% Make list of stacks available for using.
available_mice_all = mice_all;

% Make empty holder of randomized stacks. 
for mousei = 1:size(mice_all,2)
    random_mice_all(mousei).name = mice_all(mousei).name;
    for dayi = 1:size(mice_all(mousei).days, 2)
        random_mice_all(mousei).days(dayi).name = mice_all(mousei).days(dayi).name;
        for fieldi = 1:size(fields,1)
            field = fields{fieldi, 1};
            eval(['random_mice_all(mousei).days(dayi).' field '= [];']);
        end
    end
end

% For now, prevent overwriting previous randomizations
if isfile([dir_out 'mice_all_RandomSubset.mat'])
   error('mice_all_RandomSubset.mat already exists!')
end    

% For each field
for fieldi = 1:size(fields,1)
    field = fields{fieldi, 1};

    % For each mouse 
    for mousei = 1:size(mice_all,2)
        
        % Create entry in random_mice_all
        random_mice_all(mousei).name = mice_all(mousei).name;
        
        % Will go through each day, initialize counter.
        dayi = 1;

        % Until you hit the desired number of stacks for the field
        stack_total = 0;
       
        while stack_total < fields{fieldi, 2}
            
            % If the field exists in this day and is neither NaN nor empty
            if ~isfield(available_mice_all(mousei).days(dayi), field) || isempty(getfield(available_mice_all(mousei).days(dayi), field))                 dayi = dayi +1;
                dayi = dayi + 1;
                if dayi > size(mice_all(mousei).days,2)
                    dayi = 1; 
                end
                continue
            end
            % If NaN, set the corresponding random output to NaN, continue 
            if any(isnan(getfield(available_mice_all(mousei).days(dayi), field)))
                eval(['random_mice_all(mousei).days(dayi).' field '= NaN;']);
                dayi = dayi + 1;
                if dayi > size(mice_all(mousei).days,2)
                    dayi = 1; 
                end
                continue
            end    

            % Randomly pull a stack from the listed day & field. Put it
            % into random_mice_all, remove it from available_mice_all.
            stack_list = getfield(available_mice_all(mousei).days(dayi), field);
            
            % If there are no stacks left in this day, skip the day.
            if isempty(stack_list)
                dayi = dayi +1;
                if dayi > size(mice_all(mousei).days,2)
                    dayi = 1; 
                end
                continue
            end    
            index = randsample(numel(stack_list),1);

            random_mice_all(mousei).days(dayi).name = mice_all(mousei).days(dayi).name;
            eval(['random_mice_all(mousei).days(dayi).' field '(end+1)= stack_list(index);']);
            eval(['available_mice_all(mousei).days(dayi).' field '= stack_list([1:index-1 index+1:end]);']);
            
            % Increase stack counter
            stack_total = stack_total + 1;

            % Increase day iterator
            dayi = dayi + 1;

            % If this increase to day iterator is greater than the number
            % of days, put back to 1.
            if dayi > size(mice_all(mousei).days,2)
                dayi = 1; 
            end
        end     
    end
end 
mice_all = random_mice_all;
save([dir_out 'mice_all_random.mat'], 'mice_all');
