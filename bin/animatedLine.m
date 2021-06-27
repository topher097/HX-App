clc; close all;

x           = linspace(0,1000*pi,50000);
y           = sin(x);
numDisp     = 1000;

% Run plot race
[time1, time2, totalPlotTime, totalAnimateTime] = runTimer(x, y, length(x), numDisp);
close all;

% Display race timings
c = figure('Position', [200 100 1500 400]);
axs = axes('Parent', c);
hold(axs, 'on');
axis(axs, [0,length(x),0,0.04]);
plot(axs, linspace(0, length(x), length(time1)), time1, "Color", 'k');
plot(axs, linspace(0, length(x), length(time2)), time2, "Color", 'b');
legend({'Animated', 'Timer'}, 'Location', 'northeast');
hold(axs, 'off');

% Display race time sums
d = figure('Position', [200 600 1500 400]);
axs = axes('Parent', d);
hold(axs, 'on');

sumTime1 = zeros(length(time1), 0);
offset = sum(time1(1:5));
for i=1:length(time1)
    sumTime1(i) = sum(time1(1:i))-offset;
end
sumTime2 = zeros(length(time2), 0);
offset = sum(time2(1:5));
for i=1:length(time2)
    sumTime2(i) = sum(time2(1:i))-offset;
end

axis(axs, [0,length(x),0,max([max(sumTime1) max(sumTime2)])]);
plot(axs, linspace(0, length(x), length(time1)), sumTime1, "Color", 'k');
plot(axs, linspace(0, length(x), length(time2)), sumTime2, "Color", 'b');
legend({'Animated', 'Timer'}, 'Location', 'northeast');
hold(axs, 'off');

totalPlotTime
totalAnimateTime

function [time1, time2, plotTestTotalTime, plotAnimateTotalTime] = runTimer(x, y, num, numDisp)
    a = figure('Position', [200 500 600 400]);
    h = animatedline("Color", 'k');
    g = animatedline("Color", 'b');
    j = animatedline("Color", 'g');
    l = animatedline("Color", 'r');
    m = animatedline("Color", 'c');
    n = animatedline("Color", 'y');
    axis(a.CurrentAxes, [0,x(numDisp*1.1),-3,3])

    b = figure('Position', [1000 500 600 400]);
    t = gca;
    axis(t, [0,x(numDisp*1.1),-3,3])
    
    step = 10;
    y1 = y;
    y2 = y*2;
    y3 = y*3;
    y4 = -y1;
    y5 = -y2;
    y6 = -y3;
    
    animateDone = false;
    startPlotTest = 0;
    count = [];
    timeAnimated = [];
    timePlotting = [];
    start1 = tic;
    start2 = tic;
    plotTimer = timer;
    plotTimer.ExecutionMode     = 'fixedRate';
    plotTimer.Period            = 0.01;
    plotTimer.BusyMode          = 'queue';
    plotTimer.TimerFcn          = @plotTest;
    plotTimer.StartFcn          = @initTimer;
    plotTimer.StopFcn           = @animateTest;
    plotTimer.TasksToExecute    = num;
    disp("start plotting");
    start(plotTimer);
    

    function animateTest(~, ~)
        startAnimateTest = tic;
        for k=1:num
            addpoints(h,x(k),y1(k));
            addpoints(g,x(k),y2(k));
            addpoints(j,x(k),y3(k));
            addpoints(l,x(k),y4(k));
            addpoints(m,x(k),y5(k));
            addpoints(n,x(k),y6(k));

            if (mod(k,step) == 0)
                if (k>numDisp)
                    minX = x(k-numDisp);
                    if ((k+100)>num)
                        maxX = x(k);
                    else
                        maxX = x(k+100);
                    end
                    a.CurrentAxes.XLim = [minX maxX];    
                end
                drawnow limitrate
                timeAnimated(end+1) = toc(start1);
                start1 = tic;
            end
        end
        plotAnimateTotalTime = toc(startAnimateTest);
        animateDone = true;
    end
    
    
    try
        wait(plotTimer);
    catch
        stop(plotTimer);
    end
    
    disp("done");
    
    if (isvalid(plotTimer) && animateDone)
        delete(plotTimer);
        time1 = timeAnimated;
        time2 = timePlotting;
    end
    
    function plotTest(~, ~)
        try
            start2 = tic;
            count = count+step;
            hold(t, 'on');
            if (count>numDisp)
                minXplot = count-numDisp;
                if ((count+100)>num)
                    maxXplot = count;
                else
                    maxXplot = count+100;
                end
                b.CurrentAxes.XLim = [x(minXplot) x(maxXplot)];
            else
                minXplot = 1;
            end
            
            plot(t, x(minXplot:count), y1(minXplot:count), "Color", 'k');
            plot(t, x(minXplot:count), y2(minXplot:count), "Color", 'b');
            plot(t, x(minXplot:count), y3(minXplot:count), "Color", 'g');
            plot(t, x(minXplot:count), y4(minXplot:count), "Color", 'r');
            plot(t, x(minXplot:count), y5(minXplot:count), "Color", 'c');
            plot(t, x(minXplot:count), y6(minXplot:count), "Color", 'y');
            hold(t, 'off');
            timePlotting(end+1) = toc(start2);
            
        catch error
            plotTestTotalTime = toc(startPlotTest);
            disp("stopping");
            stop(plotTimer);
            return
        end
    end

    function initTimer(~, ~)
        startPlotTest = tic;
        count = 0;
    end

end


