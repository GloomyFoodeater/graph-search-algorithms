unit DynamicStructures;
{
  ������ � ������ � ��������������
  ��� ������ � ������������� �����������,
  ������������ ��� ���������� ������.
}

interface

type

  // ��� ������������ ������ � ������������ �������
  TPItem = ^TItem;

  TItem = record
    Number: Integer;
    Next: TPItem;
  end;

  // ��� ����� � ������������ �������
  TStack = TPItem;

  // ��� ������� � ������������ �������
  TQueue = record
    Head: TPItem;
    Tail: TPItem;
  end;

  // ������������ ������������� �����
procedure InitializeStack(var Stack: TStack);

// ������������ ������������� �������
procedure InitializeQueue(var Queue: TQueue);

// ������������ �������� ������
procedure DestroyList(var Head: TPItem);

// ������������ ������� � ����
procedure Push(var Stack: TStack; n: Integer);

// ������������ ���������� � �������
procedure Enqueue(var Queue: TQueue; n: Integer);

// ������������ ���������� �� �����
function Pop(var Stack: TStack): Integer;

// ������������ ���������� �� �������
function Dequeue(var Queue: TQueue): Integer;

implementation

procedure InitializeStack(var Stack: TStack);
begin

  // ��������� ��������� �� ������
  Stack := nil;
end;

procedure InitializeQueue(var Queue: TQueue);
begin

  // ��������� ���������� �� ������ � �����
  Queue.Head := nil;
  Queue.Tail := nil;
end;

procedure DestroyList(var Head: TPItem);
var
  Item: TPItem;
  // Item - ������ �� ������������� ����

begin

  // ���� �1. ������������ ������
  while Head <> nil do
  begin
    Item := Head;
    Head := Head.Next;
    Dispose(Item);
  end; // ����� �1
end;

procedure Push(var Stack: TStack; n: Integer);
var
  Item: TPItem;
  // Item - ������ �� ����������� �����

begin
  New(Item);
  Item.Number := n;
  Item.Next := Stack;
  Stack := Item;
end;

procedure Enqueue(var Queue: TQueue; n: Integer);
var
  Item: TPItem;
  // Item - ������ �� ����������� �����

begin

  // ������������� ������ ��������
  New(Item);
  Item.Number := n;
  Item.Next := nil;

  // ���������� ������ ��������
  if Queue.Head <> nil then
    Queue.Tail.Next := Item
  else
    Queue.Head := Item;

  // ����������� ������
  Queue.Tail := Item;
end;

function Pop(var Stack: TStack): Integer;
var
  Item: TPItem;
  // Item - ������ �� ����������� �����

begin

  if Stack <> nil then
  begin

    // ����������� ������� �����
    Item := Stack;
    Stack := Stack.Next;

    // ���������� �������� � ������������� ���������
    Result := Item.Number;
    Dispose(Item);
  end
  else
    Result := 0; // ������ ��� ����������

end;

function Dequeue(var Queue: TQueue): Integer;
var
  Item: TPItem;
  // Item - ������ �� ����������� �����

begin
  if Queue.Head <> nil then
  begin

    // ����������� ������ �������
    Item := Queue.Head;
    Queue.Head := Queue.Head.Next;

    // ���������� �������� � �������� ���������
    Result := Item.Number;
    Dispose(Item);
  end
  else
    Result := 0; // ������ ��� ����������
end;

end.
