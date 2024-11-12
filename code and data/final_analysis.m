



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% preparations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% uploading the ECG data:


% first, we'll upload the data all together.
% we are interested in the pulse of every subject, so instead of dealing
% with that later, we're going to extract the pulse from the data while
% uploading it (saves time, effort, and code lines...):

for i = 1:length(dir('*.txt'))/4
    baseline_vs_fast{i,1} = ((size(readtable(['bf_' num2str(i) '-events.txt']),1))-2)/3; 
    baseline_vs_fast{i,2} = ((size(readtable(['ff_' num2str(i) '-events.txt']),1))-2)/3;
    baseline_vs_slow{i,1} = ((size(readtable(['bs_' num2str(i) '-events.txt']),1))-2)/3;
    baseline_vs_slow{i,2} = ((size(readtable(['ss_' num2str(i) '-events.txt']),1))-2)/3;
end

clear i;


%% uploading the demographic data:


fast_demog_age = [24;25;25;25;26;26;25;28;27;26];
% female = 1, male = 2
fast_demog_gender = [1;1;2;2;1;1;1;2;2;1];
demog_data_fast = [fast_demog_gender,fast_demog_age];

slow_demog_age = [25;25;29;31;28;23;28;24;27;26];
% female = 1, male = 2
slow_demog_gender = [1;2;2;2;1;1;2;1;1;1];
demog_data_slow = [slow_demog_gender,slow_demog_age];

clear fast_demog_age fast_demog_gender slow_demog_age slow_demog_gender;


%% analysis of demographic data:


% avarage age of all subjects:
avg_age = mean(mean([demog_data_slow(:,2),demog_data_fast(:,2)]));
sd_age = std([demog_data_slow(:,2);demog_data_fast(:,2)]);
range_age = [min([demog_data_slow(:,2);demog_data_fast(:,2)]),max([demog_data_slow(:,2);demog_data_fast(:,2)])];

% number of females:
number_of_females = 0;
for i = 1:size(demog_data_fast,1)
    if demog_data_fast(i,1) == 1
        number_of_females = number_of_females + 1;
    end
end
for i = 1:size(demog_data_slow,1)
    if demog_data_slow(i,1) == 1
        number_of_females = number_of_females + 1;
    end
end

% number of males:
number_of_males = 0;
for i = 1:size(demog_data_fast,1)
    if demog_data_fast(i,1) == 2
        number_of_males = number_of_males + 1;
    end
end
for i = 1:size(demog_data_slow,1)
    if demog_data_slow(i,1) == 2
        number_of_males = number_of_males + 1;
    end
end

clear i;


%% general analysis of the data:


% mean BPM of each kind of measure:
mean_BPM_bf = round(mean(cell2mat(baseline_vs_fast(:,1)))); 
mean_BPM_ff = round(mean(cell2mat(baseline_vs_fast(:,2))));
mean_BPM_bs = round(mean(cell2mat(baseline_vs_slow(:,1))));
mean_BPM_ss = round(mean(cell2mat(baseline_vs_slow(:,2))));

% standart error of each kind of measure:
SE_BPM_bf = std(cell2mat(baseline_vs_fast(:,1)))/sqrt(size(cell2mat(baseline_vs_fast(:,1)),1)); 
SE_BPM_ff = std(cell2mat(baseline_vs_fast(:,2)))/sqrt(size(cell2mat(baseline_vs_fast(:,2)),1));
SE_BPM_bs = std(cell2mat(baseline_vs_slow(:,1)))/sqrt(size(cell2mat(baseline_vs_slow(:,1)),1));
SE_BPM_ss = std(cell2mat(baseline_vs_slow(:,2)))/sqrt(size(cell2mat(baseline_vs_slow(:,2)),1));




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% first analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% assumptions check before analysis:


% we want to use a paired t-test to analyze our data in each group.
% the assumption of a paired t-test is that the d's (differences) between the two samples are distributing normally in the population. 
% it's important to check whether the d's that were sampled are standing in this assumptions, with the shapiro-wilk normality test: 

% to run this section, you have to download the package: "Shapiro-Wilk and Shapiro-Francia normality tests."

% normality check for the paired t-test of the "fast" group:
[hn(1), pn(1), statsfn] = swtest(cell2mat(baseline_vs_fast(:, 2)) - cell2mat(baseline_vs_fast(:, 1)));

% normality check for the paired t-test of the "slow" group:
[hn(2), pn(2), statssn] = swtest(cell2mat(baseline_vs_slow(:, 1)) - cell2mat(baseline_vs_slow(:, 2)));

% H=0 for both, which means that both of the distribution are taken from a normal distribution 
% in the population, so we can use parametric tests on the data sets (paired t-tests).


%% analysis of the data:


% paired t-tests: 

% fast gruop:
[h(1), p(1), ci(1,:), statsf] = ttest(cell2mat(baseline_vs_fast(:, 2)), cell2mat(baseline_vs_fast(:, 1)), 'Tail', 'right');

% slow gruop:
[h(2), p(2), ci(2,:), statss] = ttest(cell2mat(baseline_vs_slow(:, 2)), cell2mat(baseline_vs_slow(:, 1)), 'Tail', 'left');

clear ci;


%% effect size:


% cohen's d test for effect size in the fast group:
cohensd_fast = meanEffectSize(cell2mat(baseline_vs_fast(:, 2)), cell2mat(baseline_vs_fast(:, 1)),"Effect","cohen" ,'Paired',true);

% cohen's d test for effect size in the fast group:
cohensd_slow = meanEffectSize(cell2mat(baseline_vs_slow(:, 1)), cell2mat(baseline_vs_slow(:, 2)),"Effect","cohen" ,'Paired',true);


%% figures of the results:


figure('Units','normalized','position',[0 0 1 1]);

the_two_means_f = [round(mean(cell2mat(baseline_vs_fast(:,1)))); round(mean(cell2mat(baseline_vs_fast(:,2))))];
subplot(1,2,1);
bar(the_two_means_f, 'FaceColor', 'b');
hold on;
error_f = [std(cell2mat(baseline_vs_fast(:,1)))/sqrt(size(cell2mat(baseline_vs_fast(:,1)),1)); std(cell2mat(baseline_vs_fast(:,2)))/sqrt(size(cell2mat(baseline_vs_fast(:,2)),1))];
errorbar(the_two_means_f,error_f, 'LineStyle','none');
title({['\fontsize{10} baseline VS fast'];['effect size (cohens d): ' num2str(cell2mat(table2cell(cohensd_fast("CohensD","Effect"))))];['p-value = ' num2str(p(1))]});
xticklabels([{'baseline'}, {'fast breathing'}]);
ylim([0, 100]);
xlabel('breathing pace');
ylabel('heart rate (beats per minutes [BPM])');

the_two_means_s = [round(mean(cell2mat(baseline_vs_slow(:,1)))); round(mean(cell2mat(baseline_vs_slow(:,2))))];
subplot(1,2,2);
bar(the_two_means_s, 'FaceColor', 'r');
hold on;
error_s = [std(cell2mat(baseline_vs_slow(:,1)))/sqrt(size(cell2mat(baseline_vs_slow(:,1)),1)); std(cell2mat(baseline_vs_slow(:,2)))/sqrt(size(cell2mat(baseline_vs_slow(:,2)),1))];
errorbar(the_two_means_s,error_s,'b', 'LineStyle','none');
title({['\fontsize{10} baseline VS slow'];['effect size (cohens d): ' num2str(cell2mat(table2cell(cohensd_slow("CohensD","Effect"))))];['p-value = ' num2str(p(2))]});
xticklabels([{'baseline'}, {'slow breathing'}]);
ylim([0, 100]);
xlabel('breathing pace');
ylabel('average heart rate (beats per minutes [BPM])');

sgtitle({['\fontsize{18} Comparisons between paired samples:']; ...
    ['\fontsize{10} \color{blue} the heart rate in the baseline breathing situation vs. fast breathing pace']; ...
    ['\color{red} the heart rate in the baseline breathing situation vs. slow breathing pace']; ...
    ['\color{black} the p-values of each paired t-test is also mentioned']});

clear the_two_means_s the_two_means_f error_s error_f;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% second analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% assumptions check before analysis:


% we want to use an unpaired t-test to compare between the differences in two different groups (slow vs. fast).
% the assumptions of an unpaired t-test are that both samples (in our case- the d's of each group) are distributing normally in the population. 
% we already checked this assumption (for both samples) for the paired t-tests, so we know this assumption stands. 
% this was the code we used:
% [hn(1), pn(1), statsfn] = swtest(cell2mat(baseline_vs_fast(:, 2)) - cell2mat(baseline_vs_fast(:, 1)));
% [hn(2), pn(2), statssn] = swtest(cell2mat(baseline_vs_slow(:, 1)) - cell2mat(baseline_vs_slow(:, 2)));

% homogeneity of variance check:

% another assumption of an unpaired t-test is that there is a homogeneity of variances between the two groups.
% we will check it by using a f-test for equal variances:
[hv1, pv1, ci, stats1var] = vartest2(cell2mat(baseline_vs_fast(:, 2)) - cell2mat(baseline_vs_fast(:, 1)), cell2mat(baseline_vs_slow(:, 1)) - cell2mat(baseline_vs_slow(:, 2)));

% the variances are not equal, so we will have to use a non-parametric test
% to compare between the differences in the two groups (slow vs. fast).

clear ci;


%% mann whitney u-test:


% this is the non-parametric version of an unpaired t-test.

d_fast = cell2mat(baseline_vs_fast(:,2)) - cell2mat(baseline_vs_fast(:,1));
d_slow = cell2mat(baseline_vs_slow(:,1)) - cell2mat(baseline_vs_slow(:,2));
[p1,h1,stats1] = ranksum(d_fast, d_slow);


%% effect size:


% cohen's d test for the effect size of manipulation type (slow/fast):
cohensd_pace = meanEffectSize(d_fast, d_slow,"Effect","cohen" ,'Paired',false);

% a big effect size...


%% figures of the results:


figure('Units','normalized','position',[0 0 1 1]);

the_two_d = [round(mean(cell2mat(baseline_vs_fast(:,2)))-mean(cell2mat(baseline_vs_fast(:,1)))); round(mean(cell2mat(baseline_vs_slow(:,1)))-mean(cell2mat(baseline_vs_slow(:,2))))];
bar(the_two_d, 'FaceColor', 'g');
hold on;
error_d = [std(cell2mat(baseline_vs_fast(:,2))-cell2mat(baseline_vs_fast(:,1)))/sqrt(size(cell2mat(baseline_vs_fast(:,1)),1)); std(cell2mat(baseline_vs_slow(:,1))-cell2mat(baseline_vs_slow(:,2)))/sqrt(size(cell2mat(baseline_vs_fast(:,2)),1))];
errorbar(the_two_d,error_d, 'LineStyle','none');
title({['\fontsize{18} Differences comparison between groups'];['\fontsize{10} differences of groups did not show homogeneity of variances'];...
     ['so we used a non-parametric test (mann whitney u-test), instead of an unpaired t-test'];[];['\fontsize{15} p-value = ' num2str(p1)];...
     ['\fontsize{10} effect size (cohens d): ' num2str(cell2mat(table2cell(cohensd_pace("CohensD","Effect"))))];['\fontsize{8} fast and slow breathing differ from each other in the intensity of effect they create on heart rate']});
xticklabels([{'baseline vs. fast breathing'}, {'baseline vs. slow breathing'}]);
ylim([0, 22]);
xlabel('breathing pace');
ylabel('average difference in heart rates (beats per minutes [BPM])');

clear the_two_d d_fast d_slow;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% control check %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% checking there is no difference between baselines:


% we want to use an unpaired t-test to check this, 
% so in this case we have to preform an assumption check 
% (because it's a parametric test):

% normal distribution:
[hn2(1), pn2(1), stats2fn] = swtest(cell2mat(baseline_vs_fast(:, 1)));
[hn2(2), pn2(2), stats2sn] = swtest(cell2mat(baseline_vs_slow(:, 1)));
% stands in this assumption so we shall continue...

% homogeneity of variances:
[hv2, pv2, ci, stats2var] = vartest2(cell2mat(baseline_vs_fast(:, 1)), cell2mat(baseline_vs_slow(:, 1)));
% stands in this assumption so we can use parametric test.

% unpaired t-test:
[h2, p2, ci2, stats2] = ttest2(cell2mat(baseline_vs_slow(:,1)),cell2mat(baseline_vs_fast(:,1)));
% not significant- meaning that the two baselines are not different...

clear ci2 ci;



