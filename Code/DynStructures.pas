unit DynStructures;

interface

type
  // Тип односвязный список с натуральными числами
  TPItem = ^TItem;

  TItem = record
    Number: Integer;
    Next: TPItem;
  end;

  // Тип стек с натуральными числами
  TStack = TPItem;

  // Тип очередь с натуральными числами
  TQueue = record
    Head: TPItem;
    Tail: TPItem;
  end;

  { Процедура инициализации стека }
procedure InitializeStack(var Stack: TStack);

{ Процедура инициализации очереди }
procedure InitializeQueue(var Queue: TQueue);

{ Процедура очищения списка }
procedure DestroyList(var Head: TPItem);

{ Процедура вставки в стек }
procedure Push(var Stack: TStack; n: Integer);

{ Процедура вставки в очередь }
procedure Enqueue(var Queue: TQueue; n: Integer);

{ Функция извлечения из стека }
function Pop(var Stack: TStack): Integer;

{ Функция извлечения из очереди }
function Dequeue(var Queue: TQueue): Integer;

{ Функция проверки списка на пустоту }
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
  // Цикл А1. Освобождение списка
  while Head <> nil do
  begin
    Item := Head;
    Head := Head.Next;
    Dispose(Item);
  end; // Конец А1
  Head := nil;
end;

procedure Push;
var
  Item: TPItem; // Вставляемое звено списка
begin

  // Инициализация нового элемента
  New(Item);
  Item.Number := n;
  Item.Next := nil;

  // Перемещение вершины стека
  if not isEmpty(Stack) then
    Item.Next := Stack;
  Stack := Item;

end;

procedure Enqueue;
var
  Item: TPItem; // Вставляемое звено списка
begin

  // Инициализация нового элемента
  New(Item);
  Item.Number := n;
  Item.Next := nil;

  // Сохранение нового элемента
  if not isEmpty(Queue.Head) then
    Queue.Tail.Next := Item
  else
    Queue.Head := Item;

  // Перемещение хвоста
  Queue.Tail := Item;
end;

function Pop(var Stack: TStack): Integer;
var
  Item: TPItem; // Извлекаемое звено списка
begin

  if not isEmpty(Stack) then
  begin
    // Перемещение вершины стека
    Item := Stack;
    Stack := Stack.Next;

    // Извлечение элемента с очисткой указателя
    Result := Item.Number;
    Dispose(Item);
  end
  else
    Result := 0; // Ошибка при извлечении

end;

function Dequeue;
var
  Item: TPItem; // Извлекаемое звено списка
begin
  if not isEmpty(Queue.Head) then
  begin

    // Перемещение начала очереди
    with Queue do
    begin
      Item := Head;
      Head := Head.Next;
    end;

    // Извлечение элемента с очисткой указателя
    Result := Item.Number;
    Dispose(Item);
  end
  else
    Result := 0; // Ошибка при извлечении
end;

function isEmpty;
begin
  Result := Head = nil;
end;

end.
