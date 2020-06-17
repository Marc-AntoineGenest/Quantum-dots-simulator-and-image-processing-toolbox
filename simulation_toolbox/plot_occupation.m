function plot_occupation(occupation, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS: 
%
% OUTPUTS:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
if isempty(varargin)
    if max(size(occupation)<=1) % 1D
        plot(occupation)
    else                        % 2D
        imagesc(flipud(occupation)) 
    end
elseif length(varargin)==1
    V_sweep1 = varargin{1};
    plot(V_sweep1, occupation)
    xlabel('Vg [V]')
    ylabel('# d''électrons')
elseif length(varargin)==2
    V_sweep1 = varargin{1};
    V_sweep2 = varargin{2};
    imagesc('XData', V_sweep2, 'YData', V_sweep1, 'CData', occupation)
    xlabel('Vg2 [V]')
    ylabel('Vg1 [V]')
    c = colorbar;
    colorTitleHandle = get(c,'Title');
    titleString = '# d''électrons';
    set(colorTitleHandle ,'String',titleString);
    scale = 0.05;
    frontier_h = scale*abs(V_sweep2(end)-V_sweep2(1));
    frontier_v = scale*abs(V_sweep1(end)-V_sweep1(1));
    xlim([V_sweep2(1)-frontier_h, V_sweep2(end)+frontier_h])
    ylim([V_sweep1(1)-frontier_v, V_sweep1(end)+frontier_v])
end
title('Occupation électronique')
colorbar
    