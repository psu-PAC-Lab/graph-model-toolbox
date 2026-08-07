classdef gmt_Plotting
%% gmt_Plotting
% Plotting class for gmt_Graph objects. Generates an interactive directed
% graph plot with oriented node labels, wrapped edge labels, and dynamic
% label updating during node drag.
%
% Usage:
%   gmt_Plotting(GraphObj)
%   gmt_Plotting(GraphObj, 'SimplifyLabels', true)
%
% Inputs:
%   GraphObj       - gmt_Graph object or subclass
%
% Name-Value Arguments:
%   'SimplifyLabels' - Replace node/edge labels with V# and E# (default: false)
%
% Note: This class was generated with the assistance of Claude (Anthropic).
%
% See also gmt_Graph, gmt_Tank

    %% Constructor
    methods (Hidden = true)

        function obj = gmt_Plotting(GraphObj, varargin)

            % Input parsing
            p = inputParser;
            addParameter(p, 'SimplifyLabels', false, @islogical);
            addParameter(p, 'EdgeLabelsOnly', false, @islogical);
            addParameter(p, 'VertexLabelsOnly', false, @islogical);
            parse(p, varargin{:});
            nodeFontSize = 10;
            edgeFontSize = 10;

            % Plot digraph
            figure
            h = plot(GraphObj.DiGraph, 'LineWidth', 5);
            
            % Scale font based on edge lengths
            G = GraphObj.DiGraph;
            edges = G.Edges.EndNodes;
            if ~isempty(edges)
                srcIdx = edges(:,1); tgtIdx = edges(:,2);
                srcX = h.XData(srcIdx); srcY = h.YData(srcIdx);
                tgtX = h.XData(tgtIdx); tgtY = h.YData(tgtIdx);
                edgeLengths = sqrt((tgtX - srcX).^2 + (tgtY - srcY).^2);
                minLen = min(edgeLengths);
                meanLen = mean(edgeLengths);
                scale = min(1.0, minLen / meanLen);
                
                % Additional scaling for very dense graphs
                nNodes = numnodes(G);
                ax = gca;
                xRng = diff(ax.XLim);
                yRng = diff(ax.YLim);
                density = nNodes / (xRng * yRng);
                if density > 3
                    densityScale = max(0.5, 3/density);
                    scale = scale * densityScale;
                end
                
                nodeFontSize = max(5, round(nodeFontSize * scale));
                edgeFontSize = max(5, round(edgeFontSize * scale));
                
                % Use minimum of the two for consistency
                minFontSize = min(nodeFontSize, edgeFontSize);
                nodeFontSize = minFontSize;
                edgeFontSize = minFontSize;
            end

            % Set title
            sgtitle(GraphObj.Name)

            % Set colors
            h.EdgeColor = GraphObj.DiGraph.Edges.EdgeColor;
            h.NodeColor = GraphObj.DiGraph.Nodes.NodeColor;

            % Arrow formatting
            h.ArrowSize     = 15;
            h.ArrowPosition = 0.80;

            % Font sizes
            h.NodeFontSize = nodeFontSize;
            h.EdgeFontSize = edgeFontSize;

            % Clear built-in labels
            h.NodeLabel = {};
            h.EdgeLabel = {};

            G   = GraphObj.DiGraph;
            ax  = ancestor(h, 'axes');
            fig = ancestor(h, 'figure');

            % Expand axis limits to prevent clipping
            margin  = 0.25;
            ax.XLim = [ax.XLim(1) - margin, ax.XLim(2) + margin];
            ax.YLim = [ax.YLim(1) - margin, ax.YLim(2) + margin];

            % Compute node label wrap width
            MaxWidth = gmtInt.gmt_Plotting.computeMaxWidth(ax, nodeFontSize, G);

            % Create node label text objects
            labelStrings = GraphObj.DiGraph.Nodes.NodeLabel;
            
            % Simplify to just V# and E# if requested
            nNodes = numel(labelStrings);
            nEdges = numel(GraphObj.DiGraph.Edges.EdgeLabel);
            edgeLabelStrings = GraphObj.DiGraph.Edges.EdgeLabel;

            changeLabels = any([p.Results.SimplifyLabels,p.Results.EdgeLabelsOnly,p.Results.VertexLabelsOnly]);

            if changeLabels

                if p.Results.SimplifyLabels || p.Results.EdgeLabelsOnly
                    for i = 1:nNodes
                        labelStrings{i} = sprintf('V%d', i);
                    end
                end

                if p.Results.SimplifyLabels || p.Results.VertexLabelsOnly
                    for e = 1:nEdges
                        edgeLabelStrings{e} = sprintf('E%d', e);
                    end
                end
                
            end
            nNodes       = numnodes(G);
            labelHandles = gobjects(1, nNodes);

            for i = 1:nNodes
                wrappedLabel = gmtInt.gmt_Plotting.wrapText(labelStrings{i}, MaxWidth);
                [dx, dy, ~, vAlign] = gmtInt.gmt_Plotting.getLabelOffset(h, G, i, nodeFontSize, p.Results.SimplifyLabels);
                labelHandles(i) = text(ax, ...
                    h.XData(i) + dx, ...
                    h.YData(i) + dy, ...
                    wrappedLabel, ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment',   vAlign, ...
                    'FontSize',            nodeFontSize, ...
                    'Interpreter',         'none', ...
                    'Clipping',            'on', ...
                    'Tag',                 'gmtNodeLabel');
            end

            % Force render so Extent is populated on node labels
            drawnow;

            % Create edge label text objects at midpoint (Pass 1)
            nEdges           = numel(edgeLabelStrings);
            edgeLabelHandles = gobjects(1, nEdges);
            edges            = G.Edges.EndNodes;

            for e = 1:nEdges
                src = edges(e, 1);
                tgt = edges(e, 2);
                [mx, my, fs, angle, edgeMaxWidth] = gmtInt.gmt_Plotting.getEdgeLabelProps(h, G, src, tgt, edgeFontSize);
                wrappedEdgeLabel = gmtInt.gmt_Plotting.wrapLine(char(edgeLabelStrings(e)), edgeMaxWidth);
                edgeLabelHandles(e) = text(ax, mx, my, ...
                    wrappedEdgeLabel, ...
                    'FontSize',            fs, ...
                    'Rotation',            angle, ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment',   'middle', ...
                    'Interpreter',         'none', ...
                    'Clipping',            'on', ...
                    'Tag',                 'gmtEdgeLabel');
            end

            % Store state in figure UserData
            fig.UserData.labelHandles     = labelHandles;
            fig.UserData.edgeLabelHandles = edgeLabelHandles;
            fig.UserData.NodeFontSize     = nodeFontSize;
            fig.UserData.EdgeFontSize     = edgeFontSize;
            fig.UserData.SimplifyLabels   = p.Results.SimplifyLabels;
            fig.UserData.initialXRange    = diff(ax.XLim);
            fig.UserData.initialYRange    = diff(ax.YLim);
            fig.UserData.DiGraph          = G;
            fig.UserData.labelStrings     = labelStrings;
            fig.UserData.edgeLabelStrings = edgeLabelStrings;

            % Pass 2: render then resolve overlaps using actual Extent
            drawnow;
            % gmtInt.gmt_Plotting.resolveOverlaps(fig, h, G);  % Disabled - causes jumping
            % gmtInt.gmt_Plotting.resolveNodeOverlaps(fig, h, G, nodeFontSize);  % Disabled - causes jumping

            % Callbacks
            fig.WindowButtonDownFcn = @(f, ~) gmtInt.gmt_Plotting.edit_graph(f, h);
            
            % Store last axis limits to detect significant zoom changes
            fig.UserData.lastXLim = ax.XLim;
            fig.UserData.lastYLim = ax.YLim;
            
            % Add listeners that only update on significant zoom (not minor pan)
            addlistener(ax, 'XLim', 'PostSet', @(~,~) gmtInt.gmt_Plotting.checkZoomAndUpdate(fig, h, ax));
            addlistener(ax, 'YLim', 'PostSet', @(~,~) gmtInt.gmt_Plotting.checkZoomAndUpdate(fig, h, ax));

        end

    end

    %% Private Static Methods
    methods (Access = private, Static)

        function edit_graph(f, h)
            a   = ancestor(h, 'axes');
            pt  = a.CurrentPoint(1, 1:2);
            dx  = h.XData - pt(1);
            dy  = h.YData - pt(2);
            len = sqrt(dx.^2 + dy.^2);
            [lmin, idx] = min(len);
            tol = max(diff(a.XLim), diff(a.YLim)) / 20;
            if lmin > tol || isempty(idx), return; end
            node    = idx(1);
            origX   = h.XData(node);
            origY   = h.YData(node);
            moved   = false;
            f.WindowButtonMotionFcn = @motion_fcn;
            f.WindowButtonUpFcn     = @release_fcn;

            function motion_fcn(~, ~)
                newx = a.CurrentPoint(1, 1);
                newy = a.CurrentPoint(1, 2);
                h.XData(node) = newx;
                h.YData(node) = newy;
                f.SizeChangedFcn = [];
                moved = true;
                gmtInt.gmt_Plotting.updateLabelsDrag(f, h);
                drawnow;
            end

            function release_fcn(~, ~)
                f.WindowButtonMotionFcn = [];
                f.WindowButtonUpFcn     = [];
                if moved
                    gmtInt.gmt_Plotting.updateLabelsDrag(f, h);
                end
                f.SizeChangedFcn = @(fig, ~) gmtInt.gmt_Plotting.onResize(fig, h);
            end
        end

        function onResize(fig, h)
            gmtInt.gmt_Plotting.updateLabels(fig, h);
        end

        function updateLabelsDrag(fig, h)
        % Lightweight label update during drag — positions only, no rewrapping
        % or overlap resolution to prevent jitter and label shrinking.

            labelHandles     = fig.UserData.labelHandles;
            edgeLabelHandles = fig.UserData.edgeLabelHandles;
            G                = fig.UserData.DiGraph;
            edgeLabelStrings = fig.UserData.edgeLabelStrings;
            nodeFontSize     = fig.UserData.NodeFontSize;
            edgeFontSize     = fig.UserData.EdgeFontSize;
            edges            = G.Edges.EndNodes;

            % Update node label positions only — keep existing string
            nNodes = numel(labelHandles);
            for i = 1:nNodes
                if ~isvalid(labelHandles(i)), continue; end
                [dx, dy, ~, vAlign] = gmtInt.gmt_Plotting.getLabelOffset(h, G, i, nodeFontSize, isfield(fig.UserData, "SimplifyLabels") && fig.UserData.SimplifyLabels);
                labelHandles(i).Position          = [h.XData(i)+dx, h.YData(i)+dy, 0];
                labelHandles(i).VerticalAlignment = vAlign;
            end

            % Update edge label positions only — keep existing string
            nEdges = numel(edgeLabelHandles);
            for e = 1:nEdges
                if ~isvalid(edgeLabelHandles(e)), continue; end
                src = edges(e,1); tgt = edges(e,2);
                [mx, my, fs, angle, ~] = gmtInt.gmt_Plotting.getEdgeLabelProps(h, G, src, tgt, edgeFontSize);
                edgeLabelHandles(e).Position = [mx, my, 0];
                edgeLabelHandles(e).FontSize = fs;
                edgeLabelHandles(e).Rotation = angle;
            end
        end

        function updateLabels(fig, h)
            labelHandles     = fig.UserData.labelHandles;
            edgeLabelHandles = fig.UserData.edgeLabelHandles;
            G                = fig.UserData.DiGraph;
            labelStrings     = fig.UserData.labelStrings;
            edgeLabelStrings = fig.UserData.edgeLabelStrings;
            nodeFontSize     = fig.UserData.NodeFontSize;
            edgeFontSize     = fig.UserData.EdgeFontSize;
            ax               = ancestor(h, 'axes');
            MaxWidth         = gmtInt.gmt_Plotting.computeMaxWidth(ax, nodeFontSize, G);
            edges            = G.Edges.EndNodes;

            % Update node labels
            nNodes = numel(labelHandles);
            for i = 1:nNodes
                if ~isvalid(labelHandles(i)), continue; end
                [dx, dy, ~, vAlign] = gmtInt.gmt_Plotting.getLabelOffset(h, G, i, nodeFontSize, isfield(fig.UserData, "SimplifyLabels") && fig.UserData.SimplifyLabels);
                wrappedLabel = gmtInt.gmt_Plotting.wrapText(labelStrings{i}, MaxWidth);
                labelHandles(i).String              = wrappedLabel;
                labelHandles(i).Position            = [h.XData(i) + dx, h.YData(i) + dy, 0];
                labelHandles(i).HorizontalAlignment = 'center';
                labelHandles(i).VerticalAlignment   = vAlign;
            end

            % Update edge labels at midpoint (Pass 1)
            nEdges = numel(edgeLabelHandles);
            for e = 1:nEdges
                if ~isvalid(edgeLabelHandles(e)), continue; end
                src = edges(e, 1);
                tgt = edges(e, 2);
                [mx, my, fs, angle, edgeMaxWidth] = gmtInt.gmt_Plotting.getEdgeLabelProps(h, G, src, tgt, edgeFontSize);
                wrappedEdgeLabel = gmtInt.gmt_Plotting.wrapLine(char(edgeLabelStrings(e)), edgeMaxWidth);
                edgeLabelHandles(e).String   = wrappedEdgeLabel;
                edgeLabelHandles(e).Position = [mx, my, 0];
                edgeLabelHandles(e).FontSize = fs;
                edgeLabelHandles(e).Rotation = angle;
            end

            % Pass 2: resolve overlaps using actual Extent
            drawnow;
            gmtInt.gmt_Plotting.resolveOverlaps(fig, h, G);
            gmtInt.gmt_Plotting.resolveNodeOverlaps(fig, h, G, nodeFontSize);
        end

        function MaxWidth = computeMaxWidth(ax, fontSize, G)
            axUnits  = ax.Units;
            ax.Units = 'pixels';
            axPos    = ax.Position;
            ax.Units = axUnits;
            axWidthPx  = axPos(3);
            axHeightPx = axPos(4);
            xRng = diff(ax.XLim);
            yRng = diff(ax.YLim);
            if xRng == 0, xRng = 1; end
            if yRng == 0, yRng = 1; end
            pxPerUnitX   = axWidthPx  / xRng;
            pxPerUnitY   = axHeightPx / yRng;
            nNodes       = max(1, numnodes(G));
            avgSpacingPx = min(pxPerUnitX * xRng, pxPerUnitY * yRng) / max(1, sqrt(nNodes));
            targetPx     = 0.30 * avgSpacingPx;
            charWidthPx  = 0.55 * fontSize;
            MaxWidth     = max(6, floor(targetPx / charWidthPx));
        end

        function [dx, dy, hAlign, vAlign] = getLabelOffset(h, G, nodeIdx, nodeFontSize, simplifyLabels)
        % Computes label offset in pixels then converts to data units.
        % Offset = half synthetic box size + gap, all computed in pixels.

            ax   = ancestor(h, 'axes');
            xRng = diff(ax.XLim);
            yRng = diff(ax.YLim);
            if xRng == 0, xRng = 1; end
            if yRng == 0, yRng = 1; end

            axUnits  = ax.Units;
            ax.Units = 'pixels';
            axPos    = ax.Position;
            ax.Units = axUnits;
            pxPerUnitX = axPos(3) / xRng;
            pxPerUnitY = axPos(4) / yRng;

            x = h.XData; y = h.YData;
            edges  = G.Edges.EndNodes;
            srcIdx = edges(:,1); tgtIdx = edges(:,2);
            connMask  = (srcIdx==nodeIdx) | (tgtIdx==nodeIdx);
            neighbors = unique([srcIdx(connMask); tgtIdx(connMask)]);
            neighbors(neighbors==nodeIdx) = [];

            if isempty(neighbors)
                angle = pi/2;
            else
                eAngles = atan2(y(neighbors)-y(nodeIdx), x(neighbors)-x(nodeIdx));
                eAngles = sort(mod(eAngles(:), 2*pi));
                if numel(eAngles)==1
                    angle = eAngles + pi;
                else
                    gaps = diff([eAngles; eAngles(1)+2*pi]);
                    [~,best] = max(gaps);
                    angle = eAngles(best) + gaps(best)/2;
                end
            end

            % Synthetic box in pixels — use representative 3 lines x 15 chars
            % For simplified labels (V#), use much smaller box
            % Scale gap based on zoom level (smaller gap when zoomed in)
            ax = ancestor(ancestor(h, 'axes'), 'figure');
            ax = ancestor(h, 'axes');
            currentXRange = diff(ax.XLim);
            currentYRange = diff(ax.YLim);
            
            % Get initial range if available, otherwise use current as baseline
            fig_ = ancestor(ax, 'figure');
            if isfield(fig_.UserData, 'initialXRange')
                initialXRange = fig_.UserData.initialXRange;
                initialYRange = fig_.UserData.initialYRange;
            else
                initialXRange = currentXRange;
                initialYRange = currentYRange;
            end
            
            % Zoom factor - linear scaling for more aggressive effect
            zoomFactorX = currentXRange / initialXRange;
            zoomFactorY = currentYRange / initialYRange;
            zoomFactor = (zoomFactorX + zoomFactorY) / 2;  % Average of both axes
            
            if simplifyLabels
                halfBoxWpx = 3 * 0.60 * nodeFontSize / 2;
                halfBoxHpx = 1 * 1.50 * nodeFontSize / 2;
                baseGapPx = max(2, round(3 * nodeFontSize / 10));
                gapPx = max(1, round(baseGapPx * zoomFactor));  % scale with zoom
            else
                halfBoxWpx = 15 * 0.60 * nodeFontSize / 2;
                halfBoxHpx = 3  * 1.50 * nodeFontSize / 2;
                baseGapPx = max(2, round(4 * nodeFontSize / 10));
                gapPx = max(1, round(baseGapPx * zoomFactor));  % scale with zoom
            end

            % Compute offset entirely in pixels
            cosA    = cos(angle);
            sinA    = sin(angle);
            dxPx    = cosA * (abs(cosA)*halfBoxWpx + abs(sinA)*halfBoxHpx + gapPx);
            dyPx    = sinA * (abs(sinA)*halfBoxHpx + abs(cosA)*halfBoxWpx + gapPx);

            % Convert to data units
            dx = dxPx / pxPerUnitX;
            dy = dyPx / pxPerUnitY;

            angleMod = mod(angle, 2*pi);
            hAlign   = 'center';
            if angleMod > pi/4 && angleMod < 3*pi/4
                vAlign = 'bottom';
            elseif angleMod > 5*pi/4 && angleMod < 7*pi/4
                vAlign = 'top';
            else
                vAlign = 'middle';
            end
        end

        function box = synthBox(lbl, pxPerUnitX, pxPerUnitY, nodeFontSize)
        % Computes synthetic bounding box for a node label text object.
        % Returns [xmin, ymin, xmax, ymax] in data units.

            charWPx = 0.60 * nodeFontSize;
            lineHPx = 1.50 * nodeFontSize;
            pos     = lbl.Position;
            lines   = lbl.String;
            if ischar(lines), lines = {lines}; end
            nLines   = numel(lines);
            maxChars = max(cellfun(@numel, lines));
            boxW = (maxChars * charWPx) / pxPerUnitX;
            boxH = (nLines  * lineHPx) / pxPerUnitY;
            lx   = pos(1); ly = pos(2);
            switch lbl.VerticalAlignment
                case 'bottom', ymin = ly;        ymax = ly + boxH;
                case 'top',    ymin = ly - boxH; ymax = ly;
                otherwise,     ymin = ly-boxH/2; ymax = ly+boxH/2;
            end
            box = [lx-boxW/2, ymin, lx+boxW/2, ymax];
        end

        function resolveNodeOverlaps(fig, h, G, nodeFontSize)
        % Moves node labels outward in their angular gap direction until
        % their synthetic box clears edges, nodes, and other node labels.

            labelHandles = fig.UserData.labelHandles;
            nNodes       = numnodes(G);

            ax   = ancestor(h, 'axes');
            xRng = diff(ax.XLim);
            yRng = diff(ax.YLim);
            if xRng == 0, xRng = 1; end
            if yRng == 0, yRng = 1; end

            % Pixels per data unit
            axUnits  = ax.Units;
            ax.Units = 'pixels';
            axPos    = ax.Position;
            ax.Units = axUnits;
            pxPerUnitX = axPos(3) / xRng;
            pxPerUnitY = axPos(4) / yRng;

            % Sample points along each edge
            edges   = G.Edges.EndNodes;
            nEdges  = size(edges, 1);
            edgePts = cell(nEdges, 1);
            for e = 1:nEdges
                s = edges(e,1); t = edges(e,2);
                nSamples = max(5, round(10 * sqrt((h.XData(t)-h.XData(s))^2 + ...
                                                   (h.YData(t)-h.YData(s))^2)));
                pts = zeros(nSamples, 2);
                for k = 1:nSamples
                    tt = (k-1)/(nSamples-1);
                    pts(k,1) = h.XData(s) + tt*(h.XData(t)-h.XData(s));
                    pts(k,2) = h.YData(s) + tt*(h.YData(t)-h.YData(s));
                end
                edgePts{e} = pts;
            end

            % Padding and step size in pixels, converted to data units per axis
            paddingPx = 6;
            stepPx    = 8;
            paddingX  = paddingPx / pxPerUnitX;
            paddingY  = paddingPx / pxPerUnitY;
            stepX     = stepPx / pxPerUnitX;
            stepY     = stepPx / pxPerUnitY;
            maxSteps  = 60;

            % Compute move direction for each node (largest angular gap)
            moveAngles = zeros(nNodes, 1);
            for n = 1:nNodes
                connMask  = (edges(:,1)==n) | (edges(:,2)==n);
                neighbors = unique([edges(connMask,1); edges(connMask,2)]);
                neighbors(neighbors==n) = [];
                if isempty(neighbors)
                    moveAngles(n) = pi/2;
                else
                    eAngles = atan2(h.YData(neighbors)-h.YData(n), ...
                                    h.XData(neighbors)-h.XData(n));
                    eAngles = sort(mod(eAngles(:), 2*pi));
                    if numel(eAngles)==1
                        moveAngles(n) = eAngles + pi;
                    else
                        gaps = diff([eAngles; eAngles(1)+2*pi]);
                        [~,best] = max(gaps);
                        moveAngles(n) = eAngles(best) + gaps(best)/2;
                    end
                end
            end

            for n = 1:nNodes
                if ~isvalid(labelHandles(n)), continue; end

                moveX = cos(moveAngles(n));
                moveY = sin(moveAngles(n));
                origPos = labelHandles(n).Position;

                for iter = 0:maxSteps
                    box = gmtInt.gmt_Plotting.synthBox(labelHandles(n), pxPerUnitX, pxPerUnitY, nodeFontSize);
                    bx1 = box(1)-paddingX; by1 = box(2)-paddingY;
                    bx2 = box(3)+paddingX; by2 = box(4)+paddingY;
                    clear_ = true;

                    % 1. Check edge line sample points
                    for e = 1:nEdges
                        pts = edgePts{e};
                        for k = 1:size(pts,1)
                            if pts(k,1)>bx1 && pts(k,1)<bx2 && ...
                               pts(k,2)>by1 && pts(k,2)<by2
                                clear_ = false; break;
                            end
                        end
                        if ~clear_, break; end
                    end

                    % 2. Check node dot positions (skip self)
                    if clear_
                        for nn = 1:nNodes
                            if nn == n, continue; end
                            if h.XData(nn)>bx1 && h.XData(nn)<bx2 && ...
                               h.YData(nn)>by1 && h.YData(nn)<by2
                                clear_ = false; break;
                            end
                        end
                    end

                    % 3. Check other node label synthetic boxes
                    if clear_
                        for nn = 1:nNodes
                            if nn == n || ~isvalid(labelHandles(nn)), continue; end
                            ob = gmtInt.gmt_Plotting.synthBox(labelHandles(nn), pxPerUnitX, pxPerUnitY, nodeFontSize);
                            % Box overlap test
                            if bx1 < ob(3)+paddingX && bx2 > ob(1)-paddingX && ...
                               by1 < ob(4)+paddingY && by2 > ob(2)-paddingY
                                clear_ = false; break;
                            end
                        end
                    end

                    % 4. Check edge label bounding boxes
                    if clear_
                        edgeLabelHandles_ = fig.UserData.edgeLabelHandles;
                        for e = 1:numel(edgeLabelHandles_)
                            if ~isvalid(edgeLabelHandles_(e)), continue; end
                            eExt = edgeLabelHandles_(e).Extent;
                            ex1 = eExt(1)-paddingX; ey1 = eExt(2)-paddingY;
                            ex2 = eExt(1)+eExt(3)+paddingX; ey2 = eExt(2)+eExt(4)+paddingY;
                            if bx1 < ex2 && bx2 > ex1 && by1 < ey2 && by2 > ey1
                                clear_ = false; break;
                            end
                        end
                    end

                    if clear_, break; end

                    % Step outward in angular gap direction
                    newX = origPos(1) + (iter+1)*stepX*moveX;
                    newY = origPos(2) + (iter+1)*stepY*moveY;
                    labelHandles(n).Position = [newX, newY, 0];
                end
            end
        end

        function [mx, my, fs, angle, edgeMaxWidth] = getEdgeLabelProps(h, G, src, tgt, baseFontSize)
        % Places edge label offset from edge midpoint such that the
        % synthetic label box does not intersect the edge line itself.

            edges  = G.Edges.EndNodes;
            nEdges = size(edges, 1);

            ax   = ancestor(h, 'axes');
            xRng = diff(ax.XLim);
            yRng = diff(ax.YLim);
            if xRng == 0, xRng = 1; end
            if yRng == 0, yRng = 1; end

            axUnits  = ax.Units;
            ax.Units = 'pixels';
            axPos    = ax.Position;
            ax.Units = axUnits;
            pxPerUnitX = axPos(3) / xRng;
            pxPerUnitY = axPos(4) / yRng;

            dxEdge  = h.XData(tgt) - h.XData(src);
            dyEdge  = h.YData(tgt) - h.YData(src);
            thisLen = sqrt(dxEdge^2 + dyEdge^2);

            % True perpendicular unit vector in data units
            if thisLen > 1e-6
                perpX = -dyEdge / thisLen;
                perpY =  dxEdge / thisLen;
            else
                perpX = 0; perpY = 1;
            end

            % Font and wrap sizing
            lengths = zeros(nEdges, 1);
            for e = 1:nEdges
                s = edges(e,1); t = edges(e,2);
                lengths(e) = sqrt((h.XData(t)-h.XData(s))^2+(h.YData(t)-h.YData(s))^2);
            end
            minLen  = max(min(lengths), 1e-6);
            meanLen = max(mean(lengths), 1e-6);
            scale   = min(1.0, minLen/meanLen);
            fs      = max(6, round(baseFontSize*scale));

            baseWidth    = 30;
            edgeMaxWidth = max(12, round(baseWidth*(thisLen/meanLen)));

            % Rotation: align label with edge direction, never upside down
            % (computed below after edgeAngleRad in pixel space)

            % Compute edge angle in pixel space for consistent perpendicular direction
            edgeAngleRad = atan2(dyEdge * pxPerUnitY, dxEdge * pxPerUnitX);
            perpAngle1   = edgeAngleRad + pi/2;
            perpAngle2   = edgeAngleRad - pi/2;

            % Pick side with more positive Y component (above the edge)
            if sin(perpAngle1) >= sin(perpAngle2)
                perpAngleRad = perpAngle1;
            else
                perpAngleRad = perpAngle2;
            end

            nLines    = max(1, ceil(20 / edgeMaxWidth));
            gapPx     = 6;
            minDistPx = (fs * 1.5) + gapPx;

            % perpAngleRad is in pixel space so cos/sin give unit pixel direction
            perpDxPx = cos(perpAngleRad);
            perpDyPx = sin(perpAngleRad);

            mx = (h.XData(src) + h.XData(tgt)) / 2 + (minDistPx * perpDxPx) / pxPerUnitX;
            my = (h.YData(src) + h.YData(tgt)) / 2 + (minDistPx * perpDyPx) / pxPerUnitY;

            angle = atan2d(dyEdge * pxPerUnitY, dxEdge * pxPerUnitX);
            if angle > 90,  angle = angle - 180; end
            if angle < -90, angle = angle + 180; end
        end

        function resolveOverlaps(fig, h, G)
        % Pass 2: Move node labels in their natural free direction if they
        % overlap with any edge label sample points.

            labelHandles     = fig.UserData.labelHandles;
            edgeLabelHandles = fig.UserData.edgeLabelHandles;
            nNodes           = numel(labelHandles);
            nEdges           = numel(edgeLabelHandles);

            ax   = ancestor(h, 'axes');
            xRng = diff(ax.XLim);
            yRng = diff(ax.YLim);

            % Sample points along each edge label
            edgePts = cell(nEdges, 1);
            for e = 1:nEdges
                if ~isvalid(edgeLabelHandles(e)), continue; end
                pos      = edgeLabelHandles(e).Position;
                eExt     = edgeLabelHandles(e).Extent;
                rotRad   = deg2rad(edgeLabelHandles(e).Rotation);
                labelLen = max(eExt(3), eExt(4));
                tSamples = linspace(-labelLen/2, labelLen/2, 9);
                pts = zeros(numel(tSamples), 2);
                for k = 1:numel(tSamples)
                    pts(k,1) = pos(1) + tSamples(k)*cos(rotRad);
                    pts(k,2) = pos(2) + tSamples(k)*sin(rotRad);
                end
                edgePts{e} = pts;
            end

            padding  = 0.03 * min(xRng, yRng);
            stepSize = 0.02 * min(xRng, yRng);
            maxSteps = 30;

            for n = 1:nNodes
                if ~isvalid(labelHandles(n)), continue; end

                % Check if this node label overlaps any edge label
                nExt = labelHandles(n).Extent;
                nx0 = nExt(1)-padding; ny0 = nExt(2)-padding;
                nw0 = nExt(3)+2*padding; nh0 = nExt(4)+2*padding;

                hasConflict = false;
                for e = 1:nEdges
                    if ~isvalid(edgeLabelHandles(e)), continue; end
                    pts = edgePts{e};
                    for k = 1:size(pts,1)
                        if pts(k,1)>nx0 && pts(k,1)<nx0+nw0 && ...
                           pts(k,2)>ny0 && pts(k,2)<ny0+nh0
                            hasConflict = true; break;
                        end
                    end
                    if hasConflict, break; end
                end

                if ~hasConflict, continue; end

                % Use the natural angular gap direction (same as getLabelOffset)
                nodeX = h.XData(n); nodeY = h.YData(n);
                edges_ = G.Edges.EndNodes;
                connMask  = (edges_(:,1)==n) | (edges_(:,2)==n);
                neighbors = unique([edges_(connMask,1); edges_(connMask,2)]);
                neighbors(neighbors==n) = [];

                if isempty(neighbors)
                    moveAngle = pi/2;
                else
                    eAngles = atan2(h.YData(neighbors)-nodeY, h.XData(neighbors)-nodeX);
                    eAngles = sort(mod(eAngles(:), 2*pi));
                    if numel(eAngles)==1
                        moveAngle = eAngles + pi;
                    else
                        gaps = diff([eAngles; eAngles(1)+2*pi]);
                        [~,best] = max(gaps);
                        moveAngle = eAngles(best) + gaps(best)/2;
                    end
                end

                moveX = cos(moveAngle);
                moveY = sin(moveAngle);

                % Step node label outward until clear
                origPos = labelHandles(n).Position;
                for iter = 1:maxSteps
                    newX = origPos(1) + iter*stepSize*moveX;
                    newY = origPos(2) + iter*stepSize*moveY;
                    labelHandles(n).Position = [newX, newY, 0];

                    nExt = labelHandles(n).Extent;
                    nx_ = nExt(1)-padding; ny_ = nExt(2)-padding;
                    nw_ = nExt(3)+2*padding; nh_ = nExt(4)+2*padding;
                    clear_ = true;
                    for e = 1:nEdges
                        if ~isvalid(edgeLabelHandles(e)), continue; end
                        pts = edgePts{e};
                        for k = 1:size(pts,1)
                            if pts(k,1)>nx_ && pts(k,1)<nx_+nw_ && ...
                               pts(k,2)>ny_ && pts(k,2)<ny_+nh_
                                clear_ = false; break;
                            end
                        end
                        if ~clear_, break; end
                    end
                    if clear_, break; end
                end
            end
        end

        function wrapped = wrapText(str, maxWidth)
        % Parses structured vertex label and returns wrapped cell array.
        % System model:    "V#: Parent: Description [Units]" -> {V#, {Parent}, Desc [Units]}
        % Component model: "V#: Description [Units]"         -> {V#, Desc [Units]}

            str = strtrim(char(str));
            token = regexp(str, '^(V\d+):\s*(.+)$', 'tokens', 'once');

            if isempty(token)
                wrapped = gmtInt.gmt_Plotting.wrapLine(str, maxWidth);
                return;
            end

            vertexNum = strtrim(token{1});
            remainder = strtrim(token{2});
            colonIdx  = strfind(remainder, ':');

            if ~isempty(colonIdx)
                parent    = strtrim(remainder(1:colonIdx(1)-1));
                descUnits = strtrim(remainder(colonIdx(1)+1:end));
                parentStr = ['{', parent, '}'];
            else
                parentStr = '';
                descUnits = remainder;
            end

            unitsToken = regexp(descUnits, '\s*(\[.+\])\s*$', 'tokens', 'once');
            if ~isempty(unitsToken)
                units = strtrim(unitsToken{1});
                desc  = strtrim(descUnits(1:end - numel(units)));
            else
                units = '';
                desc  = descUnits;
            end

            descLines = gmtInt.gmt_Plotting.wrapLineWithUnits(desc, units, maxWidth);

            if isempty(parentStr)
                wrapped = [{vertexNum}, descLines];
            else
                wrapped = [{vertexNum}, {parentStr}, descLines];
            end
        end

        function lines = wrapLineWithUnits(desc, units, maxWidth)
        % Wraps description keeping last word + units on same line.

            words = strsplit(strtrim(desc), ' ');
            words = words(~cellfun('isempty', words));

            if isempty(words)
                if isempty(units), lines = {''}; else, lines = {units}; end
                return;
            end

            lastWord = words{end};
            if isempty(units), tail = lastWord; else, tail = [lastWord, ' ', units]; end

            bodyWords = words(1:end-1);
            lines     = {};
            current   = '';

            for w = 1:numel(bodyWords)
                word = bodyWords{w};
                if isempty(current)
                    current = word;
                elseif numel(current) + 1 + numel(word) <= maxWidth
                    current = [current, ' ', word];
                else
                    lines{end+1} = current; %#ok<AGROW>
                    current = word;
                end
            end

            if isempty(current)
                lines{end+1} = tail;
            elseif numel(current) + 1 + numel(tail) <= maxWidth
                lines{end+1} = [current, ' ', tail];
            else
                lines{end+1} = current;
                lines{end+1} = tail;
            end
        end

        function lines = wrapLine(str, maxWidth)
        % Wraps a string at word boundaries to maxWidth characters.
        % Trailing numbers (e.g. "Advection 2") are kept with the preceding word.

            if numel(str) <= maxWidth
                lines = {str};
                return;
            end

            words = strsplit(str, ' ');
            words = words(~cellfun('isempty', words));

            % Merge any standalone number token with the preceding word
            merged = {};
            i = 1;
            while i <= numel(words)
                if i < numel(words) && ~isempty(regexp(words{i+1}, '^\d+$', 'once'))
                    merged{end+1} = [words{i}, ' ', words{i+1}]; %#ok<AGROW>
                    i = i + 2;
                else
                    merged{end+1} = words{i}; %#ok<AGROW>
                    i = i + 1;
                end
            end

            lines   = {};
            current = '';

            for w = 1:numel(merged)
                word = merged{w};
                if isempty(current)
                    current = word;
                elseif numel(current) + 1 + numel(word) <= maxWidth
                    current = [current, ' ', word];
                else
                    lines{end+1} = current; %#ok<AGROW>
                    current = word;
                end
            end

            if ~isempty(current)
                lines{end+1} = current;
            end
        end

        function checkZoomAndUpdate(fig, h, ax)
        % Only update labels if zoom changed significantly (>2% range change)
            if ~isfield(fig.UserData, 'lastXLim') || ~isfield(fig.UserData, 'lastYLim')
                return;
            end
            
            lastXRange = diff(fig.UserData.lastXLim);
            lastYRange = diff(fig.UserData.lastYLim);
            currentXRange = diff(ax.XLim);
            currentYRange = diff(ax.YLim);
            
            % Check if range changed >2% (zoom/home) vs <2% (pan/minor adjust)
            xChange = abs(currentXRange - lastXRange) / lastXRange;
            yChange = abs(currentYRange - lastYRange) / lastYRange;
            
            % Also check if returning to initial range (home button)
            initialXRange = fig.UserData.initialXRange;
            initialYRange = fig.UserData.initialYRange;
            xBackToInitial = abs(currentXRange - initialXRange) / initialXRange < 0.01;
            yBackToInitial = abs(currentYRange - initialYRange) / initialYRange < 0.01;
            backToHome = xBackToInitial && yBackToInitial && (xChange > 0.01 || yChange > 0.01);
            
            if xChange > 0.02 || yChange > 0.02 || backToHome
                % Significant zoom detected - update labels
                gmtInt.gmt_Plotting.updateLabels(fig, h);
                fig.UserData.lastXLim = ax.XLim;
                fig.UserData.lastYLim = ax.YLim;
            end
        end

    end % methods (Access = private, Static)

end % classdef