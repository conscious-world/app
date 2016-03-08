//
//  ReverbOutput.swift
//  EZAudio-Swift
//
//  Created by Paul Thormahlen on 12/27/15.
//

import Foundation
import AudioKit

class ReverbOutput: EZOutput{
    
    
    var reverbNodeInfo: EZAudioNodeInfo
    var delayNodeInfo: EZAudioNodeInfo
    var lowpassFilterNodeInfo: EZAudioNodeInfo
    
    
    
    override init() {
        self.reverbNodeInfo = EZAudioNodeInfo()
        self.delayNodeInfo = EZAudioNodeInfo()
        self.lowpassFilterNodeInfo = EZAudioNodeInfo()
        
        super.init()
    }
    
    
    override func connectOutputOfSourceNode(sourceNode: AUNode, sourceNodeOutputBus: UInt32, toDestinationNode destinationNode: AUNode, destinationNodeInputBus: UInt32, inGraph graph: AUGraph) -> OSStatus {
        
        self.reverbNodeInfo = EZAudioNodeInfo()
        self.delayNodeInfo = EZAudioNodeInfo()
        self.lowpassFilterNodeInfo = EZAudioNodeInfo()
        
        addReverbAudioDescriptionToGraph(graph)
        addTimeShiftAudioDescriptionToGraph(graph)
        addLowpassFilterAudioDescriptionToGraph(graph)
        
        
        // Get the reverb Audio Unit from the node
        EZAudioUtilities.checkResult(AUGraphNodeInfo(graph,self.reverbNodeInfo.node,nil,&self.reverbNodeInfo.audioUnit),
            operation:"Failed to get audio unit for reverb node");
        
        // Get the reverb Audio Unit from the node
        EZAudioUtilities.checkResult(AUGraphNodeInfo(graph,self.delayNodeInfo.node,nil,&self.delayNodeInfo.audioUnit),
            operation:"Failed to get audio unit for delay node");
        
        // Get the Hipass Audio Unit from the node
        EZAudioUtilities.checkResult(AUGraphNodeInfo(graph,self.lowpassFilterNodeInfo.node,nil,&self.lowpassFilterNodeInfo.audioUnit),
            operation:"Failed to get audio unit for delay node");
        
        // connect the output of the input source node to the input of the reverb node
        EZAudioUtilities.checkResult(AUGraphConnectNodeInput(graph,sourceNode, sourceNodeOutputBus, self.reverbNodeInfo.node,0),
            operation:"Failed to connect source node into reverb node");
        
        /* ? experiamental */
        // connect the output of the reverb node to the input of the timeshift node
        //EZAudioUtilities.checkResult(AUGraphConnectNodeInput(graph,self.reverbNodeInfo.node, 0, self.delayNodeInfo.node,0), operation:"Failed to connect source node into reverb node");
        
        // connect the output of the reverb node to the input of the timeshift node
        EZAudioUtilities.checkResult(AUGraphConnectNodeInput(graph,self.reverbNodeInfo.node, 0, self.lowpassFilterNodeInfo.node,0),
            operation:"Failed to connect source node into reverb node");
        
        
        // connect the output of the Timeshift node to the input of the destination node, thus completing the chain.
        //EZAudioUtilities.checkResult(AUGraphConnectNodeInput(graph, self.delayNodeInfo.node,0,destinationNode,destinationNodeInputBus), operation:"Failed to connect reverb to destination node");
        
        //connect the output of the hipass filter node to the input of the destination node, thus completing the chain.
        EZAudioUtilities.checkResult(AUGraphConnectNodeInput(graph, self.lowpassFilterNodeInfo.node,0,destinationNode,destinationNodeInputBus), operation:"Failed to connect reverb to destination node");
        
        // connect the output of the reverb node to the input of the destination node, thus completing the chain.
        //EZAudioUtilities.checkResult(AUGraphConnectNodeInput(graph, self.reverbNodeInfo.node,0,destinationNode,destinationNodeInputBus), operation:"Failed to connect reverb to destination node");
        
        setReverbParameters()
        setLowPassFilterParameters()
        
        
        return noErr;
    }
    
    func addReverbAudioDescriptionToGraph(graph: AUGraph){
        var reverbComponentDescription = getReverbAudioDescription()
        EZAudioUtilities.checkResult( AUGraphAddNode(graph,&reverbComponentDescription,&self.reverbNodeInfo.node), operation: "Failed to add node for reverb")
    }
    
    func addTimeShiftAudioDescriptionToGraph(graph:AUGraph){
        // A description for the time/pitch shifter Device
        var timeShiftComponentDescription = getTimeShiftAudioDescription()
        EZAudioUtilities.checkResult( AUGraphAddNode(graph,&timeShiftComponentDescription,&self.delayNodeInfo.node), operation: "Failed to add node for reverb")
    }
    
    func addLowpassFilterAudioDescriptionToGraph(graph:AUGraph){
        // A description for the time/pitch shifter Device
        var lowpassFilterComponentDescription = getLowpassAudioDescription()
        EZAudioUtilities.checkResult( AUGraphAddNode(graph,&lowpassFilterComponentDescription,&self.lowpassFilterNodeInfo.node), operation: "Failed to add node for reverb")
    }
    
    func setReverbParameters()
    {
        EZAudioUtilities.checkResult(AudioUnitSetParameter(self.reverbNodeInfo.audioUnit, kAudioUnitScope_Global, 0, kReverb2Param_DryWetMix, 90.0, 0), operation:"Failed to set kReverb2Param_DryWetMix paramater")
        
        EZAudioUtilities.checkResult(AudioUnitSetParameter(self.reverbNodeInfo.audioUnit, kReverb2Param_DecayTimeAt0Hz, kAudioUnitScope_Global, 0, 10, 0),operation:"Failed to set kReverb2Param_DecayTimeAtNyquist paramater")
        
        EZAudioUtilities.checkResult(AudioUnitSetParameter(self.reverbNodeInfo.audioUnit, kReverb2Param_DecayTimeAtNyquist, kAudioUnitScope_Global, 0, 5.0, 0),operation:"Failed to set kReverb2Param_DecayTimeAtNyquist paramater")
        
    }
    
    func setLowPassFilterParameters()
    {
        
        EZAudioUtilities.checkResult(AudioUnitSetParameter(self.lowpassFilterNodeInfo.audioUnit, kLowPassParam_CutoffFrequency, kAudioUnitScope_Global, 0, 240.0, 0), operation:"Failed to set kReverb2Param_DryWetMix paramater")
        
    }
    
    func getReverbAudioDescription() -> AudioComponentDescription
    {
        var reverbComponentDescription = AudioComponentDescription()
        reverbComponentDescription.componentType = kAudioUnitType_Effect
        reverbComponentDescription.componentSubType = kAudioUnitSubType_Reverb2
        reverbComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        reverbComponentDescription.componentFlags = 0
        reverbComponentDescription.componentFlagsMask = 0
        return reverbComponentDescription
    }
    
    func getLowpassAudioDescription() -> AudioComponentDescription
    {
        var lowpassComponentDescription = AudioComponentDescription()
        
        lowpassComponentDescription.componentType = kAudioUnitType_Effect;
        lowpassComponentDescription.componentSubType = kAudioUnitSubType_LowPassFilter;
        lowpassComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        lowpassComponentDescription.componentFlags = 0;
        lowpassComponentDescription.componentFlagsMask = 0;
        
        return lowpassComponentDescription
    }
    
    func getTimeShiftAudioDescription() -> AudioComponentDescription
    {
        var delayComponentDescription: AudioComponentDescription = AudioComponentDescription()
        delayComponentDescription.componentType = kAudioUnitType_Effect
        delayComponentDescription.componentSubType = kAudioUnitSubType_Delay
        delayComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        delayComponentDescription.componentFlags = 0
        delayComponentDescription.componentFlagsMask = 0
        return delayComponentDescription
    }
    
}