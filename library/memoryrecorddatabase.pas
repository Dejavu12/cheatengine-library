unit MemoryRecordDatabase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, MemoryRecordUnit, math, CEFuncProc;

type
TMemoryRecordTable = class
private
  records : TFPList;
  FName:string;
  function GetMemRecItemByIndex(i: integer): TMemoryRecord;
public
  procedure SelectAll;
  procedure clear;
  procedure ActivateSelected(FreezeType: TFreezeType=ftFrozen); //activates all selected entries in the addresslist
  procedure DeactivateSelected;
  function getSelectedRecord: TMemoryRecord;
  procedure setSelectedRecord(memrec: TMemoryrecord);
  procedure addAutoAssembleScript(description : string ; script: string);
  function getRecordWithID(id: integer): TMemoryRecord;
  function getRecordWithDescription(description: string): TMemoryRecord;
  procedure RefreshCustomTypes;
  procedure ReinterpretAddresses;
  function GetUniqueMemrecId: integer;
  function GetCount: integer;
  property MemRecItems[Index: Integer]: TMemoryRecord read GetMemRecItemByIndex; default;
  constructor Create();
  destructor Destroy();
published
  property Count: Integer read GetCount;
  property Name : string read FName write FName;
  property SelectedRecord: TMemoryRecord read getSelectedRecord write setSelectedRecord;
end;

implementation

procedure TMemoryRecordTable.SelectAll;
var i: integer;
begin
  for i:=0 to count-1 do
    MemRecItems[i].isSelected:=true;
end;

procedure TMemoryRecordTable.clear;
var i: integer;
begin
  //first check if it's being edited
  for i:=0 to count-1 do
    if (MemRecItems[i].isBeingEdited) then exit;

  //still here so nothing is being edited, so, delete
  while count>0 do
     MemRecItems[0].Free;
end;

procedure TMemoryRecordTable.DeactivateSelected;
var i: integer;
begin
  for i:=0 to count-1 do
    if memrecitems[i].isSelected then
      memrecitems[i].active:=false;    //this will also reset the allow* booleans
end;

procedure TMemoryRecordTable.ActivateSelected(FreezeType: TFreezeType=ftFrozen);
var
  i: integer;
  allowinc: boolean;
  allowdec: boolean;
begin
  //note, I should upgrade the memoryrecord class with this type instead of two booleans
  for i:=0 to count-1 do
    if memrecitems[i].isSelected then
    begin
      memrecitems[i].allowIncrease:=FreezeType=ftAllowIncrease;
      memrecitems[i].allowDecrease:=FreezeType=ftAllowDecrease;
      memrecitems[i].active:=true;
    end;
end;

procedure TMemoryRecordTable.setSelectedRecord(memrec: TMemoryrecord);
var i: integer;
begin
  for i:=0 to count-1 do
    if memrecitems[i]=memrec then
    begin
      memrecitems[i].isSelected:=true;
    end
    else
      memrecitems[i].isSelected:=false;
end;

function TMemoryRecordTable.getSelectedRecord: TMemoryRecord;
var i: integer;
begin
  result:=nil;
  {if treeview.selected<>nil then
    result:=TMemoryRecord(treeview.selected.data)
  else
  begin
    for i:=0 to count-1 do
      if MemRecItems[i].isSelected then
        result:=MemRecItems[i];
  end;  }
end;

procedure TMemoryRecordTable.addAutoAssembleScript(description : string ; script: string);
var
  memrec: TMemoryRecord;
begin
  memrec:=TMemoryrecord.Create(self);
  memrec.id:=GetUniqueMemrecId();
  memrec.isGroupHeader:=false;
  memrec.Description := description;
  memrec.AutoAssemblerData.script:=tstringlist.create;
  memrec.AutoAssemblerData.script.text:=script;

  memrec.VarType:=vtAutoAssembler;

  records.Add(memrec);
end;

function TMemoryRecordTable.getRecordWithDescription(description: string): TMemoryRecord;
var i: integer;
begin
  result:=nil;
  for i:=0 to count-1 do
    if uppercase(MemRecItems[i].Description)=uppercase(description) then
    begin
      result:=MemRecItems[i];
      exit;
    end;

end;

procedure TMemoryRecordTable.RefreshCustomTypes;
var i: integer;
begin
  for i:=0 to count-1 do
    MemRecItems[i].RefreshCustomType;
end;

procedure TMemoryRecordTable.ReinterpretAddresses;
var i: integer;
begin
  begin
    RefreshCustomTypes;
    for i:=0 to Count-1 do
    begin
      TMemoryRecord(records.Items[i]).ReinterpretAddress;
    end;
  end;
end;

function TMemoryRecordTable.GetUniqueMemrecId: integer;
var i: integer;
begin
  result:=-1;
  for i:=0 to records.Count-1 do
    result:=max(result, memrecitems[i].id);
  inc(result);
end;

function TMemoryRecordTable.GetCount: integer;
begin
    result:=records.Count;
end;

function TMemoryRecordTable.GetMemRecItemByIndex(i: integer): TMemoryRecord;
begin
  result:=TMemoryRecord(records.Items[i]);
end;

constructor TMemoryRecordTable.Create();
begin
  records := TFPList.Create();
end;

function TMemoryRecordTable.getRecordWithID(id: integer): TMemoryRecord;
var i: integer;
begin
  result:=nil;
  for i:=0 to count-1 do
    if MemRecItems[i].id=id then
    begin
      result:=MemRecItems[i];
      exit;
    end;
end;

destructor TMemoryRecordTable.Destroy();
begin
  records.Clear;
  records.Free;
end;

end.

