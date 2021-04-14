unit DynStructures;

interface

type
  // ��� ����������� ������ � ������������ �������
  TPList = ^TListElem;

  TListElem = record
    Elem: Cardinal;
    Next: TPList;
  end;

  // ��� ����� � ������ �������
  TStack = TPList;

  // TODO 1: �������� ������� �����
procedure InitList(var List: TPList);
procedure PushBack(var Stack: TStack; n: Integer);
function PopBack(var Stack: TStack): Cardinal;
function isEmpty(const List: TPList): Boolean;

implementation

{ ��������� ���������� �������� � ���� }
procedure PushBack;
var
  t: TStack; // ����������� ������� �����
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

{ ������� ���������� �������� ������� ����� � ��������� }
function PopBack;
var
  t: TStack; // ����������� �� ����� �������
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
    Result := 0;

end;

{ ������� �������� ������������ ��������� �� ������� }
function isEmpty;
begin
  Result := List = nil;
end;

{ ��������� ������������� ������ }
procedure InitList;
begin
  List := nil;
end;

end.
