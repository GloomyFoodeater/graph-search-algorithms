unit DynStructures;

interface

type
  // ��� ����������� ������ � ������������ �������
  TPItem = ^TItem;

  TItem = record
    Number: Integer;
    Next: TPItem;
  end;

  // ��� ���� � ������������ �������
  TStack = TPItem;

  // ��� ������� � ������������ �������
  TQueue = record
    Head: TPItem;
    Tail: TPItem;
  end;

  { ��������� ������������� ����� }
procedure InitializeStack(var Stack: TStack);

{ ��������� ������������� ������� }
procedure InitializeQueue(var Queue: TQueue);

{ ��������� �������� ������ }
procedure DestroyList(var Head: TPItem);

{ ��������� ������� � ���� }
procedure Push(var Stack: TStack; n: Integer);

{ ��������� ������� � ������� }
procedure Enqueue(var Queue: TQueue; n: Integer);

{ ������� ���������� �� ����� }
function Pop(var Stack: TStack): Integer;

{ ������� ���������� �� ������� }
function Dequeue(var Queue: TQueue): Integer;

{ ������� �������� ������ �� ������� }
function isEmpty(const Head: TPItem): Boolean;

implementation

procedure InitializeStack;
begin
  Stack := nil;
end;

procedure InitializeQueue;
begin
  Queue.Head := nil;
  Queue.Tail := nil;
end;

procedure DestroyList;
var
  Item: TPItem;
begin
  // ���� �1. ������������ ������
  while Head <> nil do
  begin
    Item := Head;
    Head := Head.Next;
    Dispose(Item);
  end; // ����� �1
  Head := nil;
end;

procedure Push;
var
  Item: TPItem; // ����������� ����� ������
begin

  // ������������� ������ ��������
  New(Item);
  Item.Number := n;
  Item.Next := nil;

  // ����������� ������� �����
  if not isEmpty(Stack) then
    Item.Next := Stack;
  Stack := Item;

end;

procedure Enqueue;
var
  Item: TPItem; // ����������� ����� ������
begin

  // ������������� ������ ��������
  New(Item);
  Item.Number := n;
  Item.Next := nil;

  // ���������� ������ ��������
  if not isEmpty(Queue.Head) then
    Queue.Tail.Next := Item
  else
    Queue.Head := Item;

  // ����������� ������
  Queue.Tail := Item;
end;

function Pop(var Stack: TStack): Integer;
var
  Item: TPItem; // ����������� ����� ������
begin

  if not isEmpty(Stack) then
  begin
    // ����������� ������� �����
    Item := Stack;
    Stack := Stack.Next;

    // ���������� �������� � �������� ���������
    Result := Item.Number;
    Dispose(Item);
  end
  else
    Result := 0; // ������ ��� ����������

end;

function Dequeue;
var
  Item: TPItem; // ����������� ����� ������
begin
  if not isEmpty(Queue.Head) then
  begin

    // ����������� ������ �������
    with Queue do
    begin
      Item := Head;
      Head := Head.Next;
    end;

    // ���������� �������� � �������� ���������
    Result := Item.Number;
    Dispose(Item);
  end
  else
    Result := 0; // ������ ��� ����������
end;

function isEmpty;
begin
  Result := Head = nil;
end;

end.
