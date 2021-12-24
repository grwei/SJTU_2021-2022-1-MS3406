function [fitresult, gof] = Rational_N2D2(y_delta_BL, u_U_BL)
%Rational_N2D2(Y_DELTA_BL,U_U_BL)
%  Create a fit.
%
%  Data for 'Rational_N2D2' fit:
%      X Input : y_delta_BL
%      Y Output: u_U_BL
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 24-Dec-2021 16:33:14 自动生成


%% Fit: 'Rational_N2D2'.
[xData, yData] = prepareCurveData( y_delta_BL, u_U_BL );

% Set up fittype and options.
ft = fittype( 'rat22' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0 -Inf -Inf];
opts.StartPoint = [0.369246781120215 0.111202755293787 0.780252068321138 0.389738836961253 0.241691285913833];
opts.Upper = [Inf Inf 0 Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'Rational_N2D2' );
h = plot( fitresult, xData, yData, 'predobs' );
set(gca,'FontName','Times New Roman','FontSize',12);
legend( h, '$$u_+$$', 'fit', 'Lower bounds', 'Upper bounds', 'Location', 'best', 'Interpreter', 'latex' );
% Label axes
xlabel( '$$y_+ := \frac{y}{\delta}$$', 'Interpreter', 'latex','FontSize',12 );
ylabel( '$$u_+ := \frac{u}{U}$$', 'Interpreter', 'latex','FontSize',12 );
title('$u_+$ - $y_+$ profile of all $x$','Interpreter','latex','FontWeight','bold')
% 创建 textbox
annotation('textbox',...
    [0.22 0.25 0.43 0.11],...
    'String',sprintf("$$u_+ = \\frac{%g y_+^2 + %g y_+}{y_+^2 + %g y_+ + %g}$$",fitresult.p1,fitresult.p2,fitresult.q1,fitresult.q2),...
    'FontSize',12,'Interpreter','latex','EdgeColor','none','FitBoxToText','on');
