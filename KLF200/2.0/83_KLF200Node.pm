##############################################################################
#
#     83_KLF200Node.pm
#     Copyright by Stefan B�nnig buennerbernd
#
##############################################################################

package main;
use strict;
use warnings;

sub KLF200Node_Initialize($) {
  my ($hash) = @_;

  $hash->{DefFn}      = 'KLF200Node_Define';
  $hash->{UndefFn}    = 'KLF200Node_Undef';
  $hash->{SetFn}      = 'KLF200Node_Set';
  $hash->{GetFn}      = 'KLF200Node_Get';
  $hash->{ReadFn}     = 'KLF200Node_Read';
  $hash->{ParseFn}    = 'KLF200Node_Parse';
  
  $hash->{AttrList}   = "disable:0,1 directionOn:up,down " . $readingFnAttributes;
  $hash->{parseParams}  = 1;
  $hash->{Match}      = ".*";

}

sub KLF200Node_Define($$) {
  my ($hash, $def) = @_;
 
  my @param= @{$def};    
  if(int(@param) < 4) {
      return "too few parameters: define <name> KLF200Node <DeviceName> <NodeID>";
  }
    
  my $DeviceName  = $param[2];
  $hash->{DeviceName} = $DeviceName;
  my $NodeID  = $param[3];
  $hash->{NodeID} = $NodeID;
  
  # Adresse r�ckw�rts dem Hash zuordnen (f�r ParseFn)
  $modules{KLF200Node}{defptr}{$DeviceName}{$NodeID} = $hash;

  KLF200Node_InitTexts($hash);
  
  return undef;
}

sub KLF200Node_InitTexts($) {
  my ($hash) = @_;
   
  $hash->{Const}->{OperatingState} = {
    0 => "Non executing",
    1 => "Error while execution",
    2 => "'Not used'",
    3 => "Waiting for power",
    4 => "Executing",
    5 => "Done",
    255 => "State unknown",
  };
  $hash->{Const}->{RunStatus} = {
    0 => "EXECUTION COMPLETED",
    1 => "EXECUTION FAILED",
    2 => "EXECUTION ACTIVE",
  };
  $hash->{Const}->{StatusReply} = {
    0x00 => "UNKNOWN STATUS REPLY",
    0x01 => "COMMAND COMPLETED OK",
    0x02 => "NO CONTACT",
    0x03 => "MANUALLY OPERATED",
    0x04 => "BLOCKED",
    0x05 => "WRONG SYSTEMKEY",
    0x06 => "PRIORITY LEVEL LOCKED",
    0x07 => "REACHED WRONG POSITION",
    0x08 => "ERROR DURING EXECUTION",
    0x09 => "NO EXECUTION",
    0x0A => "CALIBRATING",
    0x0B => "POWER CONSUMPTION TOO HIGH",
    0x0C => "POWER CONSUMPTION TOO LOW",
    0x0D => "LOCK POSITION OPEN",
    0x0E => "MOTION TIME TOO LONG  COMMUNICATION ENDED",
    0x0F => "THERMAL PROTECTION",
    0x10 => "PRODUCT NOT OPERATIONAL",
    0x11 => "FILTER MAINTENANCE NEEDED",
    0x12 => "BATTERY LEVEL",
    0x13 => "TARGET MODIFIED",
    0x14 => "MODE NOT IMPLEMENTED",
    0x15 => "COMMAND INCOMPATIBLE TO MOVEMENT",
    0x16 => "USER ACTION",
    0x17 => "DEAD BOLT ERROR",
    0x18 => "AUTOMATIC CYCLE ENGAGED",
    0x19 => "WRONG LOAD CONNECTED",
    0x1A => "COLOUR NOT REACHABLE",
    0x1B => "TARGET NOT REACHABLE",
    0x1C => "BAD INDEX RECEIVED",
    0x1D => "COMMAND OVERRULED",
    0x1E => "NODE WAITING FOR POWER",
    0xDF => "INFORMATION CODE",
    0xE0 => "PARAMETER LIMITED",
    0xE1 => "LIMITATION BY LOCAL USER",
    0xE2 => "LIMITATION BY USER",
    0xE3 => "LIMITATION BY RAIN",
    0xE4 => "LIMITATION BY TIMER",
    0xE6 => "LIMITATION BY UPS",
    0xE7 => "LIMITATION BY UNKNOWN DEVICE",
    0xEA => "LIMITATION BY SAAC",
    0xEB => "LIMITATION BY WIND",
    0xEC => "LIMITATION BY MYSELF",
    0xED => "LIMITATION BY AUTOMATIC CYCLE",
    0xEE => "LIMITATION BY EMERGENCY",
  };
  $hash->{Const}->{Velocity} = {
    0 => "DEFAULT",
    1 => "SILENT",
    2 => "FAST",
    255 => "VELOCITY NOT AVAILABLE",
  }; 
  $hash->{Const}->{NodeTypeSubType} = {
    0x0040 => "Interior Venetian Blind",
    0x0080 => "Roller Shutter",
    0x0081 => "Adjustable slats rolling shutter",
    0x0082 => "Roller Shutter With projection",
    0x00C0 => "Vertical Exterior Awning",
    0x0100 => "Window opener",
    0x0101 => "Window opener with integrated rain sensor",
    0x0140 => "Garage door opener",
    0x017A => "Garage door opener",
    0x0180 => "Light",
    0x01BA => "Light only supporting on/off",
    0x01C0 => "Gate opener",
    0x01FA => "Gate opener",
    0x0200 => "Rolling Door Opener",
    0x0240 => "Door lock",
    0x0241 => "Window lock",
    0x0280 => "Vertical Interior Blinds",
    0x0300 => "Beacon",
    0x0340 => "Dual Roller Shutter",
    0x0380 => "Heating Temperature Interface",
    0x03C0 => "On/Off switch",
    0x0400 => "Horizontal awning",
    0x0440 => "Exterior Venetian blind",
    0x0480 => "Louver blind",
    0x04C0 => "Curtain track",
    0x0500 => "Ventilation point",
    0x0501 => "Air inlet",
    0x0502 => "Air transfer",
    0x0503 => "Air outlet",
    0x0540 => "Exterior heating",
    0x057A => "Exterior heating",
    0x0580 => "Heat pump",
    0x05C0 => "Intrusion alarm",
    0x0600 => "Swinging Shutters",
    0x0601 => "Swinging Shutter with independent handling of the leaves",
  }; 
  $hash->{Const}->{NodeVariation} = {
    0 => "NOT SET",
    1 => "TOPHUNG",
    2 => "KIP",
    3 => "FLAT ROOF",
    4 => "SKY LIGHT",
  };
  $hash->{Const}->{PowerMode} = {
    0 => "ALWAYS ALIVE",
    1 => "LOW POWER MODE",
  };
  $hash->{Const}->{ioManufacturerId} = {
    1 => "VELUX",
    2 => "Somfy",
    3 => "Honeywell",
    4 => "H�rmann",
    5 => "ASSA ABLOY",
    6 => "Niko",
    7 => "WINDOW MASTER",
    8 => "Renson",
    9 => "CIAT",
    10 => "Secuyou",
    11 => "OVERKIZ",
    12 => "Atlantic Group",
  };
   
  return;
}

sub KLF200Node_GetText($$$) {
  my ($hash, $const, $id) = @_;
  
  my $text = $hash->{Const}->{$const}->{$id};
  if (not defined($text)) {return $id};
  
  return $text;
}

sub KLF200Node_Undef($$) {
  my ($hash, $arg) = @_; 
  my $NodeID = $hash->{NodeID};
  my $DeviceName = $hash->{DeviceName};
  delete $modules{KLF200Node}{defptr}{$DeviceName}{$NodeID};
  return undef;
}

sub KLF200Node_Get($@) {
  my ($hash, @param) = @_;
    # nothing to do
    return undef;
}

sub KLF200Node_Set($$$) {
  my ($hash, $argsref, undef) = @_;
  my @a= @{$argsref};
  return "set needs at least one parameter" if(@a < 2);
  
  my $name = shift @a;
  my $cmd= shift @a;
  
  if($cmd eq "state") {
    my $value = shift @a;
    return KLF200Node_SetState($hash, $value);
  }
  if($cmd eq "pct") {
    my $value = shift @a;
    return KLF200Node_SetState($hash, $value);
  }
  if ($cmd =~ /^[0-9]+$|on|off|up|down|stop/) {
    return KLF200Node_SetState($hash, $cmd);
  }
  if($cmd eq "toggle") {
    my $value;
    if    (ReadingsVal($hash->{NAME}, "operatingState", "") eq "Executing") { $value = "stop" }
    elsif (ReadingsVal($hash->{NAME}, "pct", "") < 50)                      { $value = 100 }
    else                                                                    { $value = 0 }
    return KLF200Node_SetState($hash, $value);
  }
  my $usage= "Unknown argument $cmd, choose one of";
  $usage .= " on:noArg off:noArg toggle:noArg up:noArg down:noArg stop:noArg" ;
  $usage .= " pct:slider,0,1,100" ;
  return $usage;
}

sub KLF200Node_SetState($$) {
  my ($hash, $state) = @_;
  my $name = $hash->{NAME};
  Log3($name, 5, "KLF200Node ($name) - Set $state");
  my $raw;
  if    ($state eq "stop") { $raw = 0xD200 }
  elsif ($state eq "up")   { $raw = 0x0000 }
  elsif ($state eq "down") { $raw = 0xC800 }
  elsif ($state eq "on")   { $raw = KLF200Node_PctToRaw($hash, 100) }
  elsif ($state eq "off")  { $raw = KLF200Node_PctToRaw($hash, 0) }
  else                     { $raw = KLF200Node_PctToRaw($hash, $state) }

  return KLF200Node_GW_COMMAND_SEND_REQ($hash, $raw); 
}


sub KLF200Node_Parse ($$)
{
  my ( $io_hash, $bytes) = @_;
  my $io_name = $io_hash->{NAME};
  my $hexString = unpack("H*", $bytes); 
  Log3($io_name, 5, "KLF200Node ($io_name) - received: $hexString"); 
  
  my $command = substr($bytes, 0, 2);
  if    ($command eq "\x03\x02") { return KLF200Node_GW_COMMAND_RUN_STATUS_NTF($io_hash, $bytes) }
  elsif ($command eq "\x03\x03") { return KLF200Node_GW_COMMAND_REMAINING_TIME_NTF($io_hash, $bytes) }
  elsif ($command eq "\x02\x11") { return KLF200Node_GW_NODE_STATE_POSITION_CHANGED_NTF($io_hash, $bytes) }
  elsif ($command eq "\x02\x04") { return KLF200Node_GW_GET_ALL_NODES_INFORMATION_NTF($io_hash, $bytes) }
  elsif ($command eq "\x01\x02") { return KLF200Node_GW_CS_GET_SYSTEMTABLE_DATA_NTF($io_hash, $bytes) }
  else  { Log3($io_name, 1, "KLF200Node ($io_name) - ignored:  $hexString"); return undef; }
}

sub KLF200Node_RawToPct($$) {
  my ($hash, $raw) = @_; 
  my $name = $hash->{NAME};
  my $pct;
  my $directionOn = AttrVal($name, "directionOn", "up");
  if ($directionOn eq "up") { 
    $pct = int(100 - ($raw / 512)); 
  }
  else { 
    $pct = int($raw / 512); 
  }
  return $pct;
}

sub KLF200Node_PctToRaw($$) {
  my ($hash, $pct) = @_; 
  my $name = $hash->{NAME};
  if    ($pct < 0)   {$pct = 0}
  elsif ($pct > 100) {$pct = 100};
  my $raw;
  my $directionOn = AttrVal($name, "directionOn", "up");
  if ($directionOn eq "up") { 
    $raw = int((100 - $pct) * 512); 
  }
  else { 
    $raw = int($pct * 512); 
  }  
  return $raw;
}

sub KLF200Node_BulkUpdateStatePtc($$) {
  my ($hash, $raw) = @_; 
  my $name = $hash->{NAME};
  if ($raw > 0xC800) { Log3($hash, 5, "KLF200Node ($name) unsupported position raw $raw, keep last known position"); return; }
  my $pct = KLF200Node_RawToPct($hash, $raw);
  readingsBulkUpdateIfChanged($hash, "pct", $pct, 1);
  my $state;
  if ($pct == 100) { $state = "on" }
  elsif ($pct == 0) { $state = "off" }
  else { $state = $pct }
  readingsBulkUpdateIfChanged($hash, "state", $state, 1);
}

sub KLF200Node_BulkUpdateTarget($$) {
  my ($hash, $raw) = @_; 
  my $name = $hash->{NAME};
  if ($raw > 0xC800) { Log3($hash, 5, "KLF200Node ($name) unsupported target raw $raw, keep last known target"); return; }
  my $pct = KLF200Node_RawToPct($hash, $raw);
  readingsBulkUpdateIfChanged($hash, "target", $pct, 1);
}

sub KLF200Node_GetHash($$) {
  my ($io_hash, $NodeID) = @_;
  my $DeviceName = $io_hash->{DeviceName};
  my $hash = $modules{KLF200Node}{defptr}{$DeviceName}{$NodeID};
  if(!defined($hash)) { 
    my $io_name = $io_hash->{NAME};
    my $undefined = "UNDEFINED ".$io_name."_".$NodeID." KLF200Node ".$DeviceName." ".$NodeID; 
    return (undef, $undefined); 
  };
  $hash->{IODev} = $io_hash;
  return ($hash, undef); 
}


sub KLF200Node_GW_COMMAND_RUN_STATUS_NTF($$) {
  my ($io_hash, $bytes) = @_;

  my ($commandHex, $SessionID, $StatusID, $NodeID, $NodeParameter, $ParameterValue, $RunStatus, $StatusReply, $InformationCode) 
    = unpack("H4 n H2 C C n C C H8", $bytes);

  my ($hash, $undefined) = KLF200Node_GetHash($io_hash, $NodeID);
  if (not defined($hash)) {return $undefined};

  my $name = $hash->{NAME};
  Log3($hash, 5, "KLF200Node ($name) GW_COMMAND_RUN_STATUS_NTF $commandHex $SessionID $StatusID $NodeID $NodeParameter = $ParameterValue $RunStatus $StatusReply $InformationCode");
  
  my $RunStatusStr = "Session ". $SessionID . ": " . KLF200Node_GetText($hash, "RunStatus", $RunStatus);
  my $StatusReplyStr = "Session ". $SessionID . ": " . KLF200Node_GetText($hash, "StatusReply", $StatusReply);
  readingsBeginUpdate($hash);
  if ($NodeParameter == 0) { #MP: Main Parameter
    KLF200Node_BulkUpdateStatePtc($hash, $ParameterValue);
  };
  readingsBulkUpdateIfChanged($hash, "runStatus", $RunStatusStr, 1);
  readingsBulkUpdateIfChanged($hash, "statusReply", $StatusReplyStr, 1);
  if ($RunStatus != 2) {
    readingsBulkUpdateIfChanged($hash, "remaining", 0, 1);
  }
  readingsEndUpdate($hash, 1);
  return $name;
}

sub KLF200Node_GW_COMMAND_REMAINING_TIME_NTF($$) {
  my ($io_hash, $bytes) = @_;

  my ($commandHex, $SessionID, $NodeID, $NodeParameter, $Seconds) 
    = unpack("H4 n C C n", $bytes);
    
  my ($hash, $undefined) = KLF200Node_GetHash($io_hash, $NodeID);
  if (not defined($hash)) {return $undefined};

  my $name = $hash->{NAME};    
  Log3($hash, 5, "KLF200Node ($name) GW_COMMAND_REMAINING_TIME_NTF $commandHex $SessionID $NodeID $NodeParameter = $Seconds");
  readingsBeginUpdate($hash);
  if ($NodeParameter == 0) {
    readingsBulkUpdateIfChanged($hash, "remaining", $Seconds, 1);
  };
  readingsEndUpdate($hash, 1);
  return $name;
}

sub KLF200Node_GW_NODE_STATE_POSITION_CHANGED_NTF($$) {
  my ($io_hash, $bytes) = @_;

  my ($commandHex, $NodeID, $State, $CurrentPosition, $Target, 
    $FP1CurrentPosition, $FP2CurrentPosition, $FP3CurrentPosition, $FP4CurrentPosition,
    $RemainingTime, $TimeStamp) 
    = unpack("H4 C C n n n n n n n N", $bytes); #$TimeStamp is buggy in 0.2.0.0.71.0
    
  my ($hash, $undefined) = KLF200Node_GetHash($io_hash, $NodeID);
  if (not defined($hash)) {return $undefined};

  my $name = $hash->{NAME};
  Log3($hash, 5, "KLF200Node ($name) GW_NODE_STATE_POSITION_CHANGED_NTF $commandHex $NodeID $State C:$CurrentPosition T:$Target $RemainingTime $TimeStamp");
  my $OperatingState = KLF200Node_GetText($hash, "OperatingState", $State);
  readingsBeginUpdate($hash);
  KLF200Node_BulkUpdateStatePtc($hash, $CurrentPosition);
  KLF200Node_BulkUpdateTarget($hash, $Target);
  readingsBulkUpdateIfChanged($hash, "remaining", $RemainingTime, 1);
  readingsBulkUpdateIfChanged($hash, "operatingState", $OperatingState, 1) if ($OperatingState ne "'Not used'");
  readingsEndUpdate($hash, 1);
  return $name;
}

sub KLF200Node_GW_GET_ALL_NODES_INFORMATION_NTF($$) {
  my ($io_hash, $bytes) = @_;
  
  my ($commandHex, $NodeID, $Order, $Placement, $NodeName, $Velocity, 
    $NodeTypeSubType, $ProductGroup, $ProductType, $NodeVariation, $PowerMode, $BuildNumber,
    $Serial1, $Serial2, $Serial3, $Serial4, $Serial5, $Serial6, $State, $CurrentPosition, $Target, 
    $FP1CurrentPosition, $FP2CurrentPosition, $FP3CurrentPosition, $FP4CurrentPosition,
    $RemainingTime, $TimeStamp, $NbrOfAlias, $AliasArray) 
    = unpack("H4 C n C a64 C n C C C C C C n C C C n C n n n n n n n N C H*", $bytes);
  
  my ($hash, $undefined) = KLF200Node_GetHash($io_hash, $NodeID);
  if (not defined($hash)) {return $undefined};
  
  $NodeName =~ s/\x00+$//;
  $NodeName = decode("UTF-8", $NodeName);  
  my $OperatingState = KLF200Node_GetText($hash, "OperatingState", $State);
  my $VelocityStr = KLF200Node_GetText($hash, "Velocity", $Velocity);
  my $NodeVariationStr = KLF200Node_GetText($hash, "NodeVariation", $NodeVariation);
  my $PowerModeStr = KLF200Node_GetText($hash, "PowerMode", $PowerMode);
  my $name = $hash->{NAME};
  my $klf200Time = FmtDateTime($TimeStamp);
  my $Serial = "$Serial1 $Serial2 $Serial3 $Serial4 $Serial5 $Serial6";
  Log3($hash, 5, "KLF200Node ($name) GW_GET_ALL_NODES_INFORMATION_NTF $commandHex $NodeID $NodeName $State C:$CurrentPosition T:$Target $RemainingTime $klf200Time");
  readingsBeginUpdate($hash);
  KLF200Node_BulkUpdateStatePtc($hash, $CurrentPosition);
  KLF200Node_BulkUpdateTarget($hash, $Target);
  readingsBulkUpdateIfChanged($hash, "remaining", $RemainingTime, 1);
  readingsBulkUpdateIfChanged($hash, "name", $NodeName, 1);
  readingsBulkUpdateIfChanged($hash, "operatingState", $OperatingState, 1) if ($OperatingState ne "State unknown");
  readingsBulkUpdateIfChanged($hash, "velocity", $VelocityStr, 1);
  readingsBulkUpdateIfChanged($hash, "nodeVariation", $NodeVariationStr, 1);
  readingsBulkUpdateIfChanged($hash, "powerMode", $PowerModeStr, 1);
  readingsBulkUpdateIfChanged($hash, "buildNumber", $BuildNumber, 1);
  if (defined(readingsBulkUpdateIfChanged($hash, "serial", $Serial, 1))) {
    my $year = 2000 + $Serial4;
    my (undef,undef,undef,undef,undef,$maxYear,undef,undef,undef) = localtime();
    $maxYear += 1900;
    if (($year >= 2005) and ($year <= $maxYear) and ($Serial5 <= 53)) {
      my $production = $year." week ".$Serial5;
      readingsBulkUpdate($hash, "production", $production, 1);
    }
  }
  readingsEndUpdate($hash, 1);
  $attr{$name}{alias} = $NodeName if ((not defined(AttrVal($name, "alias", undef))) and ($NodeName ne ""));
  return $name;
}

sub KLF200Node_GW_CS_GET_SYSTEMTABLE_DATA_NTF($$) {
  my ($io_hash, $bytes) = @_;
  my $io_name = $io_hash->{NAME};
  
  my ($commandHex, $NumberOfEntry) = unpack("H4 C", $bytes);

  my $result;
  for (my $i = 0; $i < $NumberOfEntry; $i++) {
    my $offset = 3 + $i * 11;
    my $SystemTableObject = substr($bytes, $offset, 11);
    my ($NodeID, $ActuatorAddress, $NodeTypeSubType, $Bits, $ioManufacturerId, $BackboneReferenceNumber) = unpack("C H6 n C C H6", $SystemTableObject);

    if ($NodeID < 200) { #Handle only actuators, ignore beacons
      my ($hash, $undefined) = KLF200Node_GetHash($io_hash, $NodeID);
      if (not defined($hash)) {
        $result = $undefined;
      }
      else {
        my $name = $hash->{NAME};
        my $ioManufacturer = KLF200Node_GetText($hash, "ioManufacturerId", $ioManufacturerId);
        my $NodeTypeSubTypeStr = $hash->{Const}->{NodeTypeSubType}->{$NodeTypeSubType};
        my $NodeType = $NodeTypeSubType & 0xFFC0;
        my $SubType = $NodeTypeSubType & 0x3F;
        my $NodeTypeSubTypeNum = $NodeType / 0x40;
        $NodeTypeSubTypeNum .= ".".$SubType if ($SubType != 0);
        if (not defined($NodeTypeSubTypeStr)) { #Match the type only.
          $NodeTypeSubTypeStr = $hash->{Const}->{NodeTypeSubType}->{$NodeType}; 
          if (not defined($NodeTypeSubTypeStr)) { $NodeTypeSubTypeStr = $NodeTypeSubTypeNum };
        };
        my $model = $ioManufacturer;
        $model .= " ".$NodeTypeSubTypeStr if ($NodeTypeSubTypeStr ne $NodeTypeSubTypeNum);
        $model .= " Type ".$NodeTypeSubTypeNum;
        readingsBeginUpdate($hash);
        readingsBulkUpdateIfChanged($hash, "ioManufacturer", $ioManufacturer, 1);
        readingsBulkUpdateIfChanged($hash, "nodeTypeSubType", $NodeTypeSubTypeStr, 1);
        readingsBulkUpdateIfChanged($hash, "model", $model, 1);
        readingsEndUpdate($hash, 1);
        $result = $name if (not defined($result));
      }
    }
  }
  my $offset = 3 + $NumberOfEntry * 11;
  my $RemainingNumberOfEntry = unpack("C", substr($bytes, $offset, 1));
  Log3($io_hash, 5, "KLF200Node ($io_name) GW_CS_GET_SYSTEMTABLE_DATA_NTF $commandHex $NumberOfEntry $RemainingNumberOfEntry");
  if ($RemainingNumberOfEntry == 0) {
    KLF200_Dequeue($io_hash, qr/^\x01\x00/, undef);
  }
  return $result;
}

sub KLF200Node_GW_COMMAND_SEND_REQ($$) {
  my ($hash, $raw) = @_;
  my $name = $hash->{NAME};    
  my $NodeId = $hash->{NodeID};
  my $Command = "\x03\x00";
  my $SessionID = 0;
  my $io_hash = $hash->{IODev};
  if (defined($io_hash)) {$SessionID = KLF200_getNextSessionID($io_hash)};
  Log3($hash, 5, "KLF200Node ($name) KLF200Node_GW_COMMAND_SEND_REQ SessionID $SessionID raw $raw");
  my $SessionIDShort = pack("n", $SessionID);
  my $CommandOriginator = "\x08"; #SAAC Stand Alone Automatic Controls 
  my $PriorityLevel = "\05"; #Comfort Level 2 Used by Stand Alone Automatic Controls 
  my $ParameterActive = "\x00";
  my $FPI1FPI2 = "\x00\x00";
  my $FunctionalParameterValueArray = pack("nx32", $raw);
  my $IndexArrayCount = pack("C", 1);
  my $IndexArray = pack("Cx19", $NodeId);
  my $PriorityLevelLock = "\x00\x00\x00\x00";

  my $bytes = $Command.$SessionIDShort.$CommandOriginator.$PriorityLevel.$ParameterActive.$FPI1FPI2
    .$FunctionalParameterValueArray.$IndexArrayCount.$IndexArray.$PriorityLevelLock;
  return IOWrite($hash, $bytes);
}

1;
