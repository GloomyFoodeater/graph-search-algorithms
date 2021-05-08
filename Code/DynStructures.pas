unit DynStructures;

interface

type
  // ��� ����������� ������ � ������������ �������
  TList = ^TNode;

  TNode = record
    Number: Integer;
    Next: TList;
  end;

  // ��� ���� � ������������ �������
  TStack = TList;

  // ��� ������� � ������������ �������
  TQueue = record
    Head: TList;
    Tail: TList;
  end;

  { ��������� ������������� ����� }
procedure InitializeStack(var Stack: TStack);

{ ��������� ������������� ������� }
procedure InitializeQueue(var Queue: TQueue);

{ ��������� �������� ������ }
procedure DestroyList(var Head: TList);

{ ��������� ������� � ���� }
procedure Push(var Stack: TStack; n: Integer);

{ ��������� ������� � ������� }
procedure Enqueue(var Queue: TQueue; n: Integer);

{ ������� ���������� �� ����� }
function Pop(var Stack: TStack): Integer;

{ ������� ���������� �� ������� }
function Dequeue(var Queue: TQueue): Integer;

{ ������� �������� ������ �� ������� }
function isEmpty(const Head: TList): Boolean;

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
  t: TList;
begin
  // ���� �1. ������������ ������
  while Head <> nil do
  begin
    t := Head;
    Head := Head.Next;
    Dispose(t);
  end; // ����� �1
  Head := nil;
end;

procedure Push;
var
  t: TList; // ����������� ����� ������
begin

  // ������������� ������ ��������
  New(t);
  t.Number := n;
  t.Next := nil;

  // ����������� ������� �����
  if not isEmpty(Stack) then
    t.Next := Stack;
  Stack := t;

end;

procedure Enqueue;
var
  t: TList; // ����������� ����� ������
begin

  // ������������� ������ ��������
  New(t);
  t.Number := n;
  t.Next := nil;

  // ���������� ������ ��������
  if not isEmpty(Queue.Head) then
    Queue.Tail.Next := t
  else
    Queue.Head := t;

  // ����������� ������
  Queue.Tail := t;
end;

function Pop;
var
  t: TList; // ����������� ����� ������
begin

  if not isEmpty(Stack) then
  begin
    // ����������� ������� �����
    t := Stack;
    Stack := Stack.Next;

    // ���������� �������� � �������� ���������
    Result := t.Number;
    Dispose(t);
  end
  else
    Result := 0; // ������ ��� ����������

end;

function Dequeue;
var
  t: TList; // ����������� ����� ������
begin
  if not isEmpty(Queue.Head) then
  begin

    // ����������� ������ �������
    with Queue do
    begin
      t := Head;
      Head := Head.Next;
    end;

    // ���������� �������� � �������� ���������
    Result := t.Number;
    Dispose(t);
  end
  else
    Result := 0; // ������ ��� ����������
end;

function isEmpty;
begin
  Result := Head = nil;
end;

end.
