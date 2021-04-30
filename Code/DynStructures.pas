unit DynStructures;

interface

type
  // ��� ����������� ������ � ������������ �������
  TPList = ^TItem;

  TItem = record
    Elem: Cardinal;
    Next: TPList;
  end;

  // ��� ���� � ������������ �������
  TStack = TPList;

  // ��� ������� � ������������ �������
  TQueue = record
    Head: TPList;
    Tail: TPList;
  end;

  { ��������� ������������� ����� }
procedure InitializeStack(var Stack: TStack);

{ ��������� ������������� ������� }
procedure InitializeQueue(var Queue: TQueue);

{ ��������� �������� ����� }
procedure DestroyStack(var Stack: TStack);

{ ��������� ������� ������� }
procedure DestroyQueue(var Queue: TQueue);

{ ��������� ������� � ���� }
procedure Push(var Stack: TStack; n: Cardinal);

{ ��������� ������� � ������� }
procedure Enqueue(var Queue: TQueue; n: Cardinal);

{ ������� ���������� �� ����� }
function Pop(var Stack: TStack): Cardinal;

{ ������� ���������� �� ������� }
function Dequeue(var Queue: TQueue): Cardinal;

{ ������� �������� ������ �� ������� }
function isEmpty(const Head: TPList): Boolean;

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

procedure DestroyStack;
var
  t: TPList;
begin
  // ���� �1. ������������ ������
  while Stack <> nil do
  begin
    t := Stack;
    Stack := Stack.Next;
    Dispose(t);
  end; // ����� �1
  Stack := nil;
end;

procedure DestroyQueue;
var
  t: TPList;
begin
  // ���� �1. ������������ ������
  while Queue.Head <> nil do
  begin
    t := Queue.Head;
    Queue.Head := Queue.Head.Next;
    Dispose(t);
  end; // ����� �1
  Queue.Head := nil;
  Queue.Tail := nil;
end;

procedure Push;
var
  t: TPList; // ����������� ����� ������
begin

  // ������������� ������ ��������
  New(t);
  t.Elem := n;
  t.Next := nil;

  // ����������� ������� �����
  if not isEmpty(Stack) then
    t.Next := Stack;
  Stack := t;

end;

procedure Enqueue;
var
  t: TPList; // ����������� ����� ������
begin

  // ������������� ������ ��������
  New(t);
  t.Elem := n;
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
  t: TPList; // ����������� ����� ������
begin

  if not isEmpty(Stack) then
  begin
    // ����������� ������� �����
    t := Stack;
    Stack := Stack.Next;

    // ���������� �������� � �������� ���������
    Result := t.Elem;
    Dispose(t);
  end
  else
    Result := 0; // ������ ��� ����������

end;

function Dequeue;
var
  t: TPList; // ����������� ����� ������
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
    Result := t.Elem;
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