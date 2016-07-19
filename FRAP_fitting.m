function FRAP_fitting(filename,dt_per_frame,w)
% filename can be the excel filename
% w is the radius of the circular FRAP ROI in m
% For example: FRAP_fitting('NBD without VAMP2_FRAP_006_norm.xlsx',0.522,2.3e-6)
close all
basefilename=filename;
base=basefilename(1:end-5);
datafilename=[base '_data_f.mat'];
data=xlsread(filename);
x=data(:,7);
index0=find(x==0);
t=data((index0+1):end,7)*dt_per_frame;
I_norm=data((index0+1):end,3);
t0=data(:,7)*dt_per_frame;
I0_norm=data(:,3);
h=figure;
plot(t0,I0_norm,'ro-','MarkerSize',8)
xlabel('Time (s)','FontSize',16);
ylabel('Normalized intensity','FontSize',16);
% define the curve as a function of the parameters x and the data t:
% x=[A,tau],xdata=t

F = @(x,xdata)x(1)*exp(-x(2)./(2*xdata)).*(besseli(0,x(2)./(2*xdata))+besseli(1,x(2)./(2*xdata)));
x0=[0.4,1];
[x,resnorm,~,exitflag,output] = lsqcurvefit(F,x0,t,I_norm)
hold on
plot(t,F(x,t),'k','LineWidth',2)
set(gca,'Fontsize',12)
A=x(1);
D=w^2/x(2); % m^2/s
strA=['Mobile fraction = ',num2str(A)];
text(0,0.95,strA,'HorizontalAlignment','left','FontSize',16);
strD=['D = ',num2str(D,'%.1e'),' m^2/s'];
text(0,0.87,strD,'HorizontalAlignment','left','FontSize',16);
strD=['or D = ',num2str((D^0.5)*1e6,'%10.2f'),' um/s'];
text(0,0.79,strD,'HorizontalAlignment','left','FontSize',16);
prompt = {'Enter the name for the plot:'};
dlg_title = 'Input (Name)';
num_lines = 1;
defaultans = {'20','hsv'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
title(answer{1},'FontSize',20);
hold off
savefig(h,[base '_FRAP_fitting.fig'])
datafilename=[base '_fitting.mat'];
save(datafilename,'x','A','D','w')
end
