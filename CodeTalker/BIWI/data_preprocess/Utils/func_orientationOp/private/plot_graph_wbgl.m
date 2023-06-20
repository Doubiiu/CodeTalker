function X = plot_graph_wbgl(A,labels)
    A = sparse(A);
    options.iterations = 200;
%     figure(1);
    
   % X = fruchterman_reingold_force_directed_layout(A,options);
   % X =  gursoy_atun_layout(A,options);
    X =  kamada_kawai_spring_layout(A,options);
    plot(X(:,1),X(:,2),'o','MarkerFaceColor','b');
    [s1, s2] = find(A>0);
    startx = X(s1,1)';
    starty = X(s1,2)';
    endx = X(s2,1)';
    endy = X(s2,2)';
    
    hold on;
    Colors = repmat([0.81 0.81 0.81],max(length(startx),1),1);
    set(gca, 'ColorOrder', Colors);
    hold on;

    plot([startx; endx],[starty; endy],'.-','LineWidth',0.1); hold on;    
    plot(X(:,1),X(:,2),'o','MarkerFaceColor','b');
    
    for k=1:size(X,1)
        t = text(X(k,1),X(k,2),labels{k},'FontSize',14);
    end
end