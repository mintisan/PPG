%-----------------------------%%-----------------------------%%
%  Authors: Alessandra Galli, Claudio Narduzzi, Giada Giorgi. %
%        Instrumentation and Measurement Research Group       %
%                    University of Padova                     %
%-----------------------------%%-----------------------------%%
function[res, s_res, gain_res, xpriori_res, Ppriori_res, ...
    inn1_res, inn2_res, VAR1_res, VAR2_res, flag1_res, flag2_res, count_res] ...
     =kalman_filter(z_ppg1,z_ppg2)
  
    Q=4^2;                  % 一直为 16
    R=10^2;                 % 一直为 100     
    
    count=0;                           
    countmax=5;
    imax=3;    
    
    xposteriori=(z_ppg1(1)+z_ppg1(1))/2;   
    res(1)=(z_ppg1(1)+z_ppg1(1))/2;        
    Pposteriori=0;                          
    s_res(1) = 0;
    gain_res(1) = 0;
    xpriori_res(1) = 0;
    Ppriori_res(1) = 0;
    inn1_res(1) = 0;
    inn2_res(1) = 0;
    VAR1_res(1) = 0;
    VAR2_res(1) = 0;
    flag1_res(1) = 0;
    flag2_res(1) = 0;
    count_res(1) = 0;
    for i=2:length(z_ppg1)
    
        xpriori=xposteriori;               % 当前次的先验心率：上一次的后验心率
        Ppriori=Pposteriori+Q;             % 当前次的先验置信度：
    
        S=Ppriori+R; 	
        gain=Ppriori/S; 
        %---------------------------------------------------------------------
        inn1=z_ppg1(i)-xpriori;   
        inn2=z_ppg2(i)-xpriori;
        
        VAR1=var(z_ppg1(max(1,(i-90)):i));           
        VAR2=var(z_ppg2(max(1,(i-90)):i));          

        %check
        if(isnan(inn1) || abs(inn1)>2*sqrt(S))
            flag1=1;
        else
            flag1=0;
        end
        %check
        if(isnan(inn2) || abs(inn2)>2*sqrt(S))
            flag2=1;
        else
            flag2=0;
        end
 
        if (VAR1*2)<VAR2  && i>20
          flag2=1;
        elseif   (VAR2*2)<VAR1  && i>20
           flag1=1;
        end 

        if((flag1==0 && flag2==0)||((count==countmax || i<imax) && (~isnan(inn1) && ~isnan(inn2))))  
     
            if(abs(inn1)<abs(inn2))
                inn=inn1;
            else
                inn=inn2;
            end
            xposteriori=xpriori+gain*inn;
            Pposteriori=(1-gain)*Ppriori;
            if(count==countmax )
                xposteriori(1)=(z_ppg1(i)+z_ppg2(i)+xpriori(1))/3;
            end
            count=0;
        elseif((flag1==0 && flag2==1)||((count==countmax || i<imax) && ~isnan(inn1)))                     
            
            inn=inn1;
            xposteriori=xpriori+gain*inn;
            Pposteriori=(1-gain)*Ppriori;
            if(count==countmax )
                xposteriori(1)=0.5*(z_ppg1(i)+xpriori(1));
            end
            count=0;
       elseif((flag2==0 && flag1==1) ||((count==countmax || i<imax) && ~isnan(inn2)))                     
     
            inn=inn2;
            xposteriori=xpriori+gain*inn;
            Pposteriori=(1-gain)*Ppriori;
            if(count==countmax )
                xposteriori(1)=0.5*(z_ppg2(i)+xpriori(1));
            end
            count=0;
        else
            count=count+1;
            xposteriori=xpriori;
            Pposteriori=Ppriori;
        end

      res(i)=xposteriori(1);
      s_res(i) = S;
      gain_res(i) = gain;
      xpriori_res(i) = xpriori;
      Ppriori_res(i) = Ppriori;
      inn1_res(i) = inn1;
      inn2_res(i) = inn2;
      VAR1_res(i) = VAR1;
      VAR2_res(i) = VAR2;
      flag1_res(i) = flag1;
      flag2_res(i) = flag2;
      count_res(i) = count;
    end
end
