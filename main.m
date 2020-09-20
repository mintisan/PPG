%-----------------------------%%-----------------------------%%
%  Authors: Alessandra Galli, Claudio Narduzzi, Giada Giorgi. %
%        Instrumentation and Measurement Research Group       %
%                    University of Padova                     %
%-----------------------------%%-----------------------------%%
clc;
clear all;
close all;

TOT_EST=[];
TOT_TRUE=[];
PPG1=[];
PPG2=[];

for k=1:12    
    
    eval(['load(''./DATI_INTERMEDI/TR',num2str(k),''');'])   
    [res, s, gain, xpriori, Ppriori, ...
        inn1, inn2, VAR1, VAR2, flag1, flag2, count]=kalman_filter(z_ppg1,z_ppg2);
    x = linspace(1, length(res), length(res));

    errore.v1(k)=mean(abs(BPM0(1:end)-res(1:end)'));
    errore.v2(k)=mean(abs(BPM0(1:end)-res(1:end)')./(BPM0(1:end)))*100;
    errore.v3(k)=max(abs(BPM0(1:end)-res(1:end)'));
    errore.v4(k)=std(abs(BPM0(1:end)-res(1:end)'));
 
    errore.r1_2s(k)=mean(abs(BPM0(1:end-1)-res(2:end)'));
    errore.r2_2s(k)=mean(abs(BPM0(1:end-1)-res(2:end)')./(BPM0(1:end-1)))*100;
    errore.r3_2s(k)=max(abs(BPM0(1:end-1)-res(2:end)'));
    errore.r4_2s(k)=std(abs(BPM0(1:end-1)-res(2:end)'));
   
    errore.r1_4s(k)=mean(abs(BPM0(1:end-2)-res(3:end)'));
    errore.r2_4s(k)=mean(abs(BPM0(1:end-2)-res(3:end)')./(BPM0(1:end-2)))*100;
    errore.r3_4s(k)=max(abs(BPM0(1:end-2)-res(3:end)'));
    errore.r4_4s(k)=std(abs(BPM0(1:end-2)-res(3:end)'));

    TOT_EST=[TOT_EST res(3:end)];
    TOT_TRUE=[TOT_TRUE, BPM0(1:end-2)'];

    PPG1=[PPG1 z_ppg1(3:end)];
    PPG2=[PPG2 z_ppg2(3:end)];

    h = figure(k);				% 创建图形窗口
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');	% 关闭相关的警告提示（因为调用了非公开接口）
    jFrame = get(h,'JavaFrame');	% 获取底层 Java 结构相关句柄吧
    pause(0.1);					% 在 Win 10，Matlab 2017b 环境下不加停顿会报 Java 底层错误。各人根据需要可以进行实验验证
    set(jFrame,'Maximized',1);	%设置其最大化为真（0 为假）
    pause(0.1);					% 个人实践中发现如果不停顿，窗口可能来不及变化，所获取的窗口大小还是原来的尺寸。各人根据需要可以进行实验验证
    warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');		% 打开相关警告设置
%     set(h,'visible','off');     % 不显示

	subplot(2,2,1);
    scatter(x, z_ppg1, 'o');hold on;scatter(x, z_ppg2, '*');
    hold on;plot(x, xpriori); hold on;plot(x, Ppriori); hold on; plot(x, s)
    hold on;plot(x, res);
    legend("ppg1","ppg2","xpriori","Ppriori","s","res");
    subplot(2,2,2);
	plot(x, VAR1);hold on;plot(x, VAR2);
    yyaxis right;
    hold on;plot(x, inn1);hold on;plot(x, inn2);
    legend("VAR1","VAR2","inn1","inn2");
    subplot(2,2,3);
    hold on;scatter(x, flag1);hold on;scatter(x, flag2);
    yyaxis right;
    hold on;plot(gain);
    legend("flag1","flag2","gain");
    print(gcf, '-r300','-djpeg', "./DATI_RES/"+ num2str(k)+".jpeg")
    close all;
end 






