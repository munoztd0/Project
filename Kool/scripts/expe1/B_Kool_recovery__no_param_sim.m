
%=========================================================================%
% Simulation script for parameter recovery and model identifiability
% Adappted from Correa et al. (2018) J.Neuro (https://doi.org/10.1523/JNEUROSCI.0457-18.2018)
% and Kool, Gershman, Cushman (2018) J.CogNeuro (https://doi.org/10.1162/jocn_a_01263)
% Needs Matlab R2014b or more recent, Matlab's Statistics and Machine Learning and optimization 
% toolboxes, and the VBA toolbox (https://mbb-team.github.io/VBA-toolbox/)
% Author: David Munoz Tord - david.munoz@etu.unige.ch


%18 min per sb per it

% clc
% clear
% close all
% 
% rng('shuffle')

% % %%%
% cd ~/Project/VBA-toolbox/
% VBA_setup()
% 
% cd ~/Project/Kool/data/
% % %%%
% 
% dbstop if error
% 
% try 
%     VBA_version;
% catch
%     warning('You should download the VBA toolbox (https://mbb-team.github.io/VBA-toolbox/) to run the code')
% end
% 
% 
% %% load data
% load('SUBDATA')
% load('PARAMS')


%# declare variables
nsub    = 7; 
iterations = 2; 
models = 10; 
param = 7;
ntrials = 200; 


% set estimation options
options     = optimset('Algorithm', 'interior-point', 'MaxIter', 1000000);

%% parameteres ; 
%beta1, beta2, alpha1, alpha2, w1, w2, lambda
LB = [0 0 0 0 0 0 0]; % lower bounds 
%UB = [20 20 20 1 1 1 1 1]; %  upper bounds = 20 ok but random UP = 4??
UB = [10 10 1 1 1 1 1]; 
%in their simulation they found w r = 0.68, p < 0.001, r = 0.25, p < 0.001, r = 0.82, p < 0.001, and eligibility trace decay parameter, r = 0.27, p < 0.001

%notes
%so for now stage 0 at 0.5
KK = [1 0 1 0 1 0 0;... 1 - 1w  / no lambda / 1beta 1 alpha
      1 0 1 0 1 1 0;... 2 - 2w  / no lambda  / 1beta 1 alpha
      1 0 1 0 1 0 1;... 3 - 1w  + lambda  / 1beta 1 alpha
      1 0 1 0 1 1 1;... 4 - 2w  + lambda  / 1beta 1 alpha 
      1 1 1 0 1 1 0;... 5 - 2 betas 2w  / no lambda  / 1 alpha
      1 1 1 0 1 1 1;... 6 - 2 betas 2w  + lambda  / 1 alpha
      1 0 1 1 1 1 0;... 7 - 2 alphas 2w  / no lambda  / 1beta
      1 0 1 1 1 1 1;... 8 - 2 alphas 2w  + lambda   / 1beta       
      1 1 1 1 1 1 0;... 9 - full 6  / no lambda
      1 1 1 1 1 1 1];%...10 - full 6 + lambda   
      

%     1 0 1 0 1 1 0 0;... %The transition-dependent learning rates (TDLR) algorithm
%     1 0 1 0 1 1 0 0];... %The unlucky-symbol algorithm

%nfpm = [3 4 4 5 5 6 5 6 6 7];
nfpm = [3 3 3 3 3 3 3 3 3 3];

  

tic
%% simulation loop
for k_it = 1:iterations %# 50 before
    tic
    clear ll ll_rep bic recov_param
    %close all force
       
%     % simulate with all possible models
%     for k_sim = 1:models
%   
%         % sample parameters %should the same subject have the same
%         % parameters?
%         n   = nsub;
%         
%         B1  = random('Gamma',4,.5,n,1);
%         B2  = random('Gamma',4,.5,n,1);
%         %B1 = median(params.model(:,1));
% 
%         LR1 = random('Beta',5,1.5,n,1);
%         LR2 = random('Beta',5,1.5,n,1);
%         %LR = median(params.model(:,2));
%         
%         LAMBDA  = random('Normal',0.5,0.1,n,1); %makes sense?
%         %LAMBDA = median(params.model(:,3));
%         
%         W1  = random('Uniform',0,1,n,1);
%         W2  = random('Uniform',0,1,n,1);
%      
% 
%         % simulate data
         for k_sub=1:nsub
%               
%             get task structure from behavioral data
%             data = SUBDATA(k_sub); 
%             con  = data.high_effort; %%% 
% 
%             simulate behavior with sampled parameters . // B2(k_sub), B3(k_sub),
%             SimRun(k_it).simu_param(k_sub,k_sim,:)  = [B1(k_sub), B2(k_sub), LR1(k_sub), LR2(k_sub), W1(k_sub), W2(k_sub),LAMBDA(k_sub)].*KK(k_sim,:); %
% 
%             addpath ~/Project/mfit/
%             cd ~/Project/Kool/scripts/expe1
% 
%             % Rewards
%             data.bounds = [0 9];
%             data.sd = 2;
%             rews = C_i_generate_rews(ntrials,data.bounds,data.sd);
%             rews = rews./9;
% 
%             % SARS
%             output  = C_ii_kool_sim(squeeze(SimRun(k_it).simu_param(k_sub,k_sim,:)),con, rews, k_sim);   %# returns S A R & S1
%             SimRun(k_it).rewardrate(k_sim).val(k_sub) = sum(output.R)/length(output.R); 
%             re-estimate parameters with all possible models
%             
%             for k_est=1:models 
%                 x0                                                  = [10*rand() 10*rand() rand() rand() rand() rand() rand()];% parameter initial value ?ok at ten?            
%                 [parameters_rep(1,1:param),ll_rep]                  = fmincon(@(x) C_iii_kool_model_ll(x,con, output, k_est),x0,[],[],[],[],LB,UB,[],options); %changed out by rews
%                                                [x,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
%                 SimRun(k_it).recov_param(k_sim).val(k_sub,k_est,:)  = parameters_rep(1,1:param).*KK(k_est,:);
%                 SimRun(k_it).ll(k_sim).val(k_sub,k_est)             = ll_rep;
%             end
%         end
     end
  
    % model comparison step, for each simulation
    for k_sim = 1:models 
        
        
        LL                                      = SimRun(k_it).ll(k_sim).val; 
        for n=1:models
            
            SimRun(k_it).bic(:,n)               = -2*-LL(:,n) + nfpm(n)*log(ntrials); % bayesian Information criterion = -2*L + k*log(n)
            SimRun(k_it).aic(:,n)               = -2*log(LL(:,n))+ 2*nfpm(n);  %AIC=2k-2log(L)

        end     
        [posteriorAdo,outAdo]                   = VBA_groupBMC(-SimRun(k_it).bic'./2); 
        SimRun(k_it).BMC_output(k_sim).post     = posteriorAdo;
        SimRun(k_it).BMC_output(k_sim).out      = outAdo;
        
        [posteriorAdoAIC,outAdoAIC]                = VBA_groupBMC(-SimRun(k_it).aic'); %??
        SimRun(k_it).BMC_outputAIC(k_sim).post     = posteriorAdoAIC;
        SimRun(k_it).BMC_outputAIC(k_sim).out      = outAdoAIC;
        
    end
    
    disp(['Iteration ', num2str(k_it), '/', num2str(k_sub),'.'])
    toc
    close all force
end
toc
%% save files
n_iter = num2str(iterations);
save('SIMU_Kool_test_no_param','SimRun')

%% notes


