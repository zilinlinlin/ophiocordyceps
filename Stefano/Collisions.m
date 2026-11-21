clear; clc; clear all; close all;

dump = readmatrix('collision_times.csv');

time_lim = dump(:, 1);
collision_times = dump(:, 2);
collision_counts = dump(:, 3);
infection_times = dump(:, 4);
infection_counts = dump(:, 5);

% [w, b] = fit_line(dump, 100000, 10e-8); % my estimation
p_c = polyfit(collision_times, collision_counts, 1);

% collision_estimations = collision_times.*w + ones(length(collision_times), 1).*b;
collision_estimations_mat = collision_times.*p_c(1) + ones(length(collision_times), 1).*p_c(2);


figure(1)
plot(collision_times, collision_counts, '-', 'Color', 'blue', 'LineWidth', 2)
xlabel('Time (t)')
ylabel('Count (n)')
ylim([0, time_lim(end)])

hold on
% plot(collision_times, collision_estimations, '--r')
plot(collision_times, collision_estimations_mat, '--g', 'LineWidth', 2)
grid on

% error = sum(abs(collision_estimations - collision_counts));
error_mat = sum(abs(collision_estimations_mat - collision_counts));

% if error < error_mat
%     disp('Better')
% else
%     disp('Worse')
% end
% disp([num2str(error), ' to ', num2str(error_mat)])

figure(2)

% fit('poly2', infection_times, infection_counts)

plot(infection_times, infection_counts, '-', 'Color', 'red', 'LineWidth', 2)