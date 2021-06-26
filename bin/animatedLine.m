clc; close all;

x = linspace(0,20*pi,1000);
y = sin(x);

% Run plot race
[time1, time2] = runTimer(x, y, length(x));

% Display race timings
figure('Position', [200 100 600 400]);
hold(gca, 'on');
axis(gca, [0,length(x),0,0.012]);
plot(gca, linspace(0, length(x), length(time1)), time1, "Color", 'k');
plot(gca, linspace(0, length(x), length(time2)), time2, "Color", 'b');
legend({'Animated', 'Timer'}, 'Location', 'northeast');
hold(gca, 'off');

function [time1, time2] = runTimer(x, y, num)
    a = figure('Position', [200 500 600 400]);
    h = animatedline("Color", 'k');
    g = animatedline("Color", 'b');
    j = animatedline("Color", 'g');
    l = animatedline("Color", 'r');
    m = animatedline("Color", 'c');
    n = animatedline("Color", 'y');
    axis(a.CurrentAxes, [0,max(x),-3,3])

    figure('Position', [1000 500 600 400]);
    t = gca;
    axis(t, [0,max(x),-3,3])
    
    count = [];
    timeAnimated = [];
    timePlotting = [];
    start1 = tic;
    start2 = tic;
    plotTimer = timer;
    plotTimer.ExecutionMode     = 'fixedRate';
    plotTimer.Period            = 0.005;
    plotTimer.BusyMode          = 'queue';
    plotTimer.TimerFcn          = @plotTest;
    plotTimer.StartFcn          = @initTimer;
    plotTimer.TasksToExecute    = num;
    disp("start plotting");
    start(plotTimer);
    
    step = 5;
    y1 = y;
    y2 = y*2;
    y3 = y*3;
    y4 = -y1;
    y5 = -y2;
    y6 = -y3;
    
    for k=1:num
        addpoints(h,x(k),y1(k));
        addpoints(g,x(k),y2(k));
        addpoints(j,x(k),y3(k));
        addpoints(l,x(k),y4(k));
        addpoints(m,x(k),y5(k));
        addpoints(n,x(k),y6(k));

        if (mod(k,step) == 0)
           drawnow limitrate
           timeAnimated(end+1) = toc(start1);
           start1 = tic;
        end
    end
    
    try
        wait(plotTimer);
    catch
        stop(plotTimer);
    end
    
    disp("done");
    
    if (isvalid(plotTimer) && k == num)
        delete(plotTimer);
        time1 = timeAnimated;
        time2 = timePlotting;
    end
    
    function plotTest(~, ~)
        try
            start2 = tic;
            count = count+step;
            hold(t, 'on');
            plot(t, x(1:count), y1(1:count), "Color", 'k');
            plot(t, x(1:count), y2(1:count), "Color", 'b');
            plot(t, x(1:count), y3(1:count), "Color", 'g');
            plot(t, x(1:count), y4(1:count), "Color", 'r');
            plot(t, x(1:count), y5(1:count), "Color", 'c');
            plot(t, x(1:count), y6(1:count), "Color", 'y');
            hold(t, 'off');
            timePlotting(end+1) = toc(start2);
            
        catch
            disp("stopping");
            stop(plotTimer);
            return
        end
    end

    function initTimer(~, ~)
        count = 0;
    end
end


