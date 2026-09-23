function f = plotVI(t,I,V)

f = figure(Position=[0,0,600,200]);
tiledlayout('flow', 'Padding', 'compact', 'TileSpacing', 'compact')

nexttile
hold on; grid on; axis('padded')
plot(t,I)
ylabel('Current (A)'); xlabel('Time (s)')

nexttile
hold on; grid on; axis('padded')
plot(t,V,'r')
ylabel('Voltage (V)'); xlabel('Time (s)')
end
