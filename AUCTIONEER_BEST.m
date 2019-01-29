function [I,J,SS, BB, loss_1, total_sur, Q_buyer, Q_seller, p_trade_buyer, p_trade_seller,total_buyer_sur, total_seller_sur] = AUCTIONEER_BEST(num_sub_buyer, num_sub_seller, sorted_sub_buyers, sorted_sub_sellers);
Q_seller = [];
Q_buyer = [];

%%%find seller I and buyer J
SS = sorted_sub_sellers(:,2);
BB = sorted_sub_buyers(:,2);

sorted_seller = sorted_sub_sellers;
sorted_buyer = sorted_sub_buyers;
%% i for seller
%% j for buyer
I = 0; J = 0;

%%%%too many buyers
for j = 2:1:num_sub_buyer
    if sum(SS) <= sum(BB(1:j))
        if sorted_buyer(j,1) > sorted_seller(num_sub_seller,1)
            I = num_sub_seller;
            J = j;
            break;
        end
    end
end

for j = 2:1:num_sub_buyer
    if sorted_buyer(j,1)>= sorted_seller(num_sub_seller,1) & sorted_seller(num_sub_seller,1)>= sorted_buyer(j+1,1) & ...
                sum(SS(1:num_sub_seller-1))<= sum(BB(1:j)) &  sum(BB(1:j)) <= sum(SS(1:num_sub_seller))
            I = num_sub_seller;
            J = j;
            break
    end
    
    if sorted_seller(num_sub_seller,1) >= sorted_buyer(j,1) & sorted_buyer(j,1)>= sorted_seller(num_sub_seller-1,1) & ...
                    sum(BB(1:j-1)) <= sum(SS(1:num_sub_seller-1)) & sum(SS(1:num_sub_seller-1))<= sum(BB(1:j))
                I = num_sub_seller-1;
                J = j;
                break;
    end
    
end
  
% %%% too many sellers
    
for i = 2:1:num_sub_seller
    if sum(BB) <= sum(SS(1:i))
        if sorted_buyer(num_sub_buyer,1) > sorted_seller(i,1)
            I = i;
            J = num_sub_buyer;
            break;
        end
    end
end

for i = 2:1:num_sub_seller
    if sorted_buyer(num_sub_buyer-1,1)>= sorted_seller(i,1) & sorted_seller(i,1)>= sorted_buyer(num_sub_buyer,1) & ...
                sum(SS(1:i-1))<= sum(BB(1:num_sub_buyer-1)) &  sum(BB(1:num_sub_buyer-1)) <= sum(SS(1:i))
            I = i;
            J = num_sub_buyer - 1;
            break;
    end
    
%     if sorted_seller(i+1,1) >= sorted_buyer(num_sub_buyer,1) & sorted_buyer(num_sub_buyer,1)>= sorted_seller(i,1) &  sum(BB(1:num_sub_buyer-1)) <= sum(SS(1:i)) & sum(SS(1:i))<= sum(BB(1:num_sub_buyer))
      if sum(BB(1:num_sub_buyer-1)) <= sum(SS(1:i)) & sum(SS(1:i))<= sum(BB(1:num_sub_buyer)) & sorted_buyer(num_sub_buyer,1)>= sorted_seller(i,1) & sorted_seller(i+1,1) >= sorted_buyer(num_sub_buyer,1)      
                I = i;
                J = num_sub_buyer;
                break;
    end
  
end

if I == 0 & J == 0
   
for i = 2:1:num_sub_seller-1
    for j = 2:1:num_sub_buyer-1
%%%%case I condition        
        if sorted_buyer(j,1)>= sorted_seller(i,1) & sorted_seller(i,1)>= sorted_buyer(j+1,1) & ...
                sum(SS(1:i-1))<= sum(BB(1:j)) &  sum(BB(1:j)) <= sum(SS(1:i))
            I = i;
            J = j;
            break;
%%%case II condition            
        else if sorted_seller(i+1,1) >= sorted_buyer(j,1) & sorted_buyer(j,1)>= sorted_seller(i,1) & ...
                    sum(BB(1:j-1)) <= sum(SS(1:i)) & sum(SS(1:i))<= sum(BB(1:j))
                I = i;
                J = j;
                break;
            end
        end
    end
end
end

p_trade_buyer = sorted_buyer(J,1);
p_trade_seller = sorted_seller(I,1);

total_buyer_sur = 0;
total_seller_sur = 0;

for j = 1:1:J-1
    total_buyer_sur = total_buyer_sur + sorted_buyer(j,2)*(sorted_buyer(j,1) - p_trade_buyer);
end

for i = 1:1:I-1
    total_seller_sur = total_seller_sur + sorted_seller(i,2)*( p_trade_seller - sorted_seller(i,1));
end

total_sur_3 = (p_trade_buyer - p_trade_seller)* min(sum(BB(1:J)), sum(SS(1:I)));

total_sur = total_buyer_sur + total_seller_sur + total_sur_3;

%%%demand > supply
if sum(BB(1:J-1)) >= sum(SS(1:I-1))
    
    %%%seller    
    for i = 1:1:I-1
        Q_seller(i,1) = sorted_seller(i,1);
        Q_seller(i,2) = sorted_seller(i,2);
        Q_seller(i,3) = sorted_seller(i,3);
    end
    
    for i = I:1:num_sub_seller
        Q_seller(i,1) = sorted_seller(i,1);
        Q_seller(i,2) = 0;
        Q_seller(i,3) = sorted_seller(i,3);
    end
    
    %%buyer
    for j = 1:1:J-1
        Q_buyer(j,1) = sorted_buyer(j,1);
        Q_buyer(j,2) = sorted_buyer(j,2) - (sum(BB(1:J-1)) - sum(SS(1:I-1)))*BB(j)/(sum(BB(1:J-1)));
        Q_buyer(j,3) = sorted_buyer(j,3);
    end
    for j = J:1:num_sub_buyer
        Q_buyer(j,1) = sorted_buyer(j,1);
        Q_buyer(j,2) = 0;
        Q_buyer(j,3) = sorted_buyer(j,3);
    end
    
else
    
    %%%buyer
    for j = 1:1:J-1
        Q_buyer(j,1) = sorted_buyer(j,1);
        Q_buyer(j,2) = sorted_buyer(j,2);
        Q_buyer(j,3) = sorted_buyer(j,3);
    end
    
    for j = J:1:num_sub_buyer
        Q_buyer(j,1) = sorted_buyer(j,1);
        Q_buyer(j,2) = 0;
        Q_buyer(j,3) = sorted_buyer(j,3);
    end
         
    %%%seller
    
    for i =1:1:I-1
        Q_seller(i,1) = sorted_seller(i,1);
        Q_seller(i,2) = sorted_seller(i,2) - (sum(SS(1:I-1)) - sum(BB(1:J-1)))*SS(i)/sum(SS(1:I-1));
        Q_seller(i,3) = sorted_seller(i,3);
    end
    
    for i = I:1:num_sub_seller
        Q_seller(i,1) = sorted_seller(i,1);
        Q_seller(i,2) = 0;
        Q_seller(i,3) = sorted_seller(i,3);
    end
    
end

loss_1 = min( sum(BB(1:J)), sum(SS(1:I))) * (p_trade_buyer - p_trade_seller);
end

