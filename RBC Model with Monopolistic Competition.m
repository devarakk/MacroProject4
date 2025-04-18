%Part A
% RBC Model with Monopolistic Competition and Technology Shocks

var c k l y i w r z;
varexo eps;

parameters alpha beta delta psi rho epsilon;

alpha = 0.33;
beta = 0.99;
delta = 0.025;
psi = 1.75;
rho = 0.95;
epsilon = 10;

model;
  // 1. Euler Equation
  1/c = beta * (1/c(+1)) * (1 + r(+1) - delta);

  // 2. Labor-Leisure Condition
  psi * c / (1 - l) = w;

  // 3. Resource Constraint
  c + i = y;

  // 4. Production Function
  y = k(-1)^alpha * (exp(z) * l)^(1 - alpha);

  // 5. Real Wage
  w = y * (epsilon - 1)/epsilon * (1 - alpha) / l;

  // 6. Real Interest Rate
  r = y * (epsilon - 1)/epsilon * alpha / k(-1);

  // 7. Capital Accumulation
  i = k - (1 - delta) * k(-1);

  // 8. Technology Process
  z = rho * z(-1) + eps;
end;

initval;
  z = 0;
  eps = 0;
  l = 0.3;
  k = 1;
  y = k^alpha * (exp(z) * l)^(1 - alpha);
  c = y - delta * k;
  i = delta * k;
  w = y * (epsilon - 1)/epsilon * (1 - alpha) / l;
  r = y * (epsilon - 1)/epsilon * alpha / k;
end;

shocks;
  var eps;
  periods 1:5;
  values 0.1;
end;

perfect_foresight_setup(periods=100);
perfect_foresight_solver;


%Part B
% Get dimensions
sim_data = oo_.endo_simul;
num_periods = size(sim_data, 2) - 1; % exclude initial period
time = 1:num_periods;

% Variable positions
pos_c = strmatch('c', M_.endo_names, 'exact');
pos_y = strmatch('y', M_.endo_names, 'exact');
pos_k = strmatch('k', M_.endo_names, 'exact');
pos_l = strmatch('l', M_.endo_names, 'exact');

% Extract paths (skip initial column)
c_path = sim_data(pos_c, 2:end);
y_path = sim_data(pos_y, 2:end);
k_path = sim_data(pos_k, 2:end);
l_path = sim_data(pos_l, 2:end);

% Plotting
figure;
subplot(2,2,1);
plot(time, c_path(:), 'b', 'LineWidth', 2);
title('Consumption'); xlabel('Periods'); ylabel('c');

subplot(2,2,2);
plot(time, y_path(:), 'g', 'LineWidth', 2);
title('Output'); xlabel('Periods'); ylabel('y');

subplot(2,2,3);
plot(time, k_path(:), 'm', 'LineWidth', 2);
title('Capital'); xlabel('Periods'); ylabel('k');

subplot(2,2,4);
plot(time, l_path(:), 'r', 'LineWidth', 2);
title('Labor'); xlabel('Periods'); ylabel('l');

sgtitle('Impulse Response Functions (Perfect Foresight Simulation)');

>> 