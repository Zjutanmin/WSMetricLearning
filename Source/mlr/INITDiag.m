function Diagnostics = INITDiag(Loss, Feature, k, Regularizer, Diagonal, C, E, FEASIBLE_COUNT, ConstraintClock)
Diagnostics = struct('loss',                 Loss, ...           % Which loss are we optimizing?
    'feature',              Feature, ...        % Which ranking feature is used?
    'k',                    k, ...              % What is the ranking length?
    'regularizer',          Regularizer, ...    % What regularization is used?
    'diagonal',             Diagonal, ...       % 0 for full metric, 1 for diagonal
    'num_calls_SO',         0, ...              % Calls to separation oracle
    'num_calls_solver',     0, ...              % Calls to solver
    'time_SO',              0, ...              % Time in separation oracle
    'time_solver',          0, ...              % Time in solver
    'time_total',           0, ...              % Total time
    'f',                    [], ...             % Objective value
    'num_steps',            [], ...             % Number of steps for each solver run
    'num_constraints',      [], ...             % Number of constraints for each run
    'Xi',                   [], ...             % Slack achieved for each run
    'Delta',                [], ...             % Mean loss for each SO call
    'gap',                  [], ...             % Gap between loss and slack
    'C',                    C, ...              % Slack trade-off
    'epsilon',              E, ...              % Convergence threshold
    'feasible_count',       FEASIBLE_COUNT, ... % Counter for # svd's
    'constraint_timer',     ConstraintClock);   % Time before evicting old constraints

