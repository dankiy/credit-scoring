data_path = '../data/';

cs_training = readtable(strcat(data_path, 'cs-training.csv'));
cs_training.MonthlyIncome = str2double(cs_training.MonthlyIncome);
cs_clean = cs_training(~strcmp(cs_training.MonthlyIncome, 'NA') & (cs_training.MonthlyIncome > 1) & (cs_training.MonthlyIncome <= 25000) ...
                    & (cs_training.age <= 80) & (cs_training.age >= 21) ... 
                    & ((cs_training.NumberOfTime30_59DaysPastDueNotWorse + cs_training.NumberOfTime60_89DaysPastDueNotWorse + cs_training.NumberOfTimes90DaysLate <= 10)), ...
                    {'age', 'MonthlyIncome', 'NumberOfTime30_59DaysPastDueNotWorse', 'NumberOfTime60_89DaysPastDueNotWorse', 'NumberOfTimes90DaysLate', 'SeriousDlqin2yrs'});
cs_clean.Properties.VariableNames = {'Age', 'Income', 'PastDue', 'PastDue60', 'PastDue90', 'Default'};
cs_clean.PastDue = cs_clean.PastDue + cs_clean.PastDue60 + cs_clean.PastDue90;
cs_clean = cs_clean(:, {'Age', 'Income', 'PastDue', 'Default'});

trueRows = find(cs_clean.Default == 1);
falseRows = find(cs_clean.Default == 0);
falseRows = falseRows(randperm(length(falseRows)));
falseRows  = falseRows(1:length(trueRows));
cs_balanced = cs_clean(sort([falseRows, trueRows]), :);
cs_balanced = cs_balanced(randperm(size(cs_balanced, 1)), :);
cs_balanced = cs_clean;

rng(0);
cv_test = cvpartition(size(cs_balanced,1),'HoldOut',0.1);
idx_test = cv_test.test;
cs_train_val = cs_balanced(~idx_test,:);
cs_test = cs_balanced(idx_test,:);
cv_val = cvpartition(size(cs_train_val,1),'HoldOut',0.1);
idx_val = cv_val.test;
cs_train_matrix = cs_train_val{~idx_val,:};
cs_val_matrix = cs_train_val{idx_val,:};

writetable(cs_test, strcat(data_path, 'cs-test.csv'));
save(strcat(data_path, 'cs-train.dat'),'cs_train_matrix','-ascii','-double','-tabs');
save(strcat(data_path, 'cs-val.dat'),'cs_val_matrix','-ascii','-double','-tabs');