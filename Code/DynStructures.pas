unit DynStructures;

interface

type
  // ��� ����������� ������ � ������������ �������
  TPList = ^TItem;

  TItem = record
    Elem: Cardinal;
    Next: TPList;
  end;

  // ��� ����� � ������ �������
  TStack = TPList;

  { ��������� ������������� ������ }
procedure InitializeList(var Head: TPList);

{ ��������� �������� ������ }
procedure DestroyList(var Head: TPList);

{ ��������� ������� � ���� }
procedure Push(var Head: TStack; n: Integer);

{ ������� ���������� �� ����� }
function Pop(var Head: TStack): Cardinal;

{ ������� �������� ������ �� ������� }
function isEmpty(const Head: TPList): Boolean;

implementation

procedure Push;
var
  t: TStack; // ����������� ������� �����
begin

  // ������������� ������ ��������
  New(t);
  t.Elem := n;
  t.Next := nil;

  // ����������� ������� �����
  if not isEmpty(Head) then
    t.Next := Head;
  Head := t;

end;

function Pop;
var
  t: TStack; // ����������� �� ����� �������
begin

  if not isEmpty(Head) then
  begin
    // ����������� ������� �����
    t := Head;
    Head := Head.Next;

    // ���������� �������� � �������� ���������
    Result := t.Elem;
    Dispose(t);
  end
  else
    Result := 0;

end;

function isEmpty;
begin
  Result := Head = nil;
end;

procedure InitializeList;
begin
  Head := nil;
end;

procedure DestroyList;
var
  t: TPList;
begin
  // TODO 1: �������� ������� ������
end;

end.
