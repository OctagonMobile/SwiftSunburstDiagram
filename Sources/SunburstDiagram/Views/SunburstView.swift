//
//  SunburstView.swift
//  SunburstDiagram
//
//  Created by Ludovic Landry on 6/10/19.
//  Copyright © 2019 Ludovic Landry. All rights reserved.
//

import SwiftUI

public struct SunburstView: View {

    @ObservedObject var sunburst: Sunburst
        
    public init(configuration: SunburstConfiguration) {
        sunburst = configuration.sunburst
    }
    
    public var body: some View {
        let arcs = ZStack {
            configureViews(arcs: sunburst.rootArcs)
            
            // Stop the window shrinking to zero when there is no arcs.
            Spacer()
        }
        .flipsForRightToLeftLayoutDirection(true)
        .padding()

        let drawnArcs = arcs.drawingGroup()
        return drawnArcs
    }
    
    public func highlightNodes(withName name: String) {
        let nodesToHighlight = highlightNodes(nodes: self.sunburst.configuration.nodes,
                                              name: name)
        self.sunburst.configuration.highlightedNodes = nodesToHighlight
    }
    
    private func highlightNodes(nodes: [Node],
                                name: String) -> [Node] {
        var highlightedNodes: [Node] = []
        for node in nodes {
            if node.name == name {
                highlightedNodes.append(node)
            }

            let highlightedChildren = highlightNodes(nodes: node.children,
                                                     name: name)
            highlightedNodes += highlightedChildren
        }
        return highlightedNodes
    }
    
    private func configureViews(arcs: [Sunburst.Arc], parentArc: Sunburst.Arc? = nil) -> some View {
        return ForEach(arcs) { arc in
            ArcView(arc: arc, configuration: self.sunburst.configuration).onTapGesture {
                guard self.sunburst.configuration.allowsSelection else { return }
                if self.sunburst.configuration.highlightedNodes?.isEmpty == false {
                    self.sunburst.configuration.highlightedNodes?.removeAll()
                } else if self.sunburst.configuration.selectedNode == arc.node && self.sunburst.configuration.focusedNode == arc.node {
                    self.sunburst.configuration.focusedNode = self.sunburst.configuration.parentForNode(arc.node)
                } else if self.sunburst.configuration.selectedNode == arc.node {
                    if self.sunburst.configuration.shouldFocusNode  {
                        self.sunburst.configuration.focusedNode = arc.node
                    } else {
                        self.sunburst.configuration.selectedNode = nil
                    }
                } else {
                    self.sunburst.configuration.selectedNode = arc.node
                }
            }
            IfLet(arc.childArcs) { childArcs in
                AnyView(self.configureViews(arcs: childArcs, parentArc: arc))
            }
        }
    }
}

#if DEBUG
struct SunburstView_Previews : PreviewProvider {
    static var previews: some View {
        let configuration = SunburstConfiguration(nodes: [
            Node(name: "Walking",
                 showName: false,
                 value: 10.0,
                 backgroundColor: .systemBlue),
            Node(name: "Restaurant",
                 showName: false,
                 value: 30.0,
                 backgroundColor: .systemRed),
            Node(name: "Home",
                 showName: false,
                 value: 75.0,
                 backgroundColor: .systemTeal)
        ])
        return SunburstView(configuration: configuration)
    }
}
#endif
