unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Menus, GraphSearch, Digraph,
  DynStructures, GraphDrawing, AboutForm;

type

  // Тип режима работы с графом
  TClickState = (stAddVertice, stAddArc, stDeleteVertice, stDeleteArc, stDFS,
    stBFS, stDijkstra, stNone);
  TVerFile = File of TVertice;
  TArcFile = File of TItem;

  TfrmGraphEditor = class(TForm)
    plFunctionsContainer: TPanel;
    AddNodeBtn: TSpeedButton;
    AddLinkBtn: TSpeedButton;
    DeleteNodeBtn: TSpeedButton;
    DeleteLinkBtn: TSpeedButton;
    DFSBtn: TSpeedButton;
    BFSbtn: TSpeedButton;
    DijkstraBtn: TSpeedButton;
    imGraphCanvas: TImage;
    mmMain: TMainMenu;
    nFile: TMenuItem;
    nEdit: TMenuItem;
    nHelp: TMenuItem;
    nSave: TMenuItem;
    nExit: TMenuItem;
    nClear: TMenuItem;
    nAbout: TMenuItem;
    N1: TMenuItem;
    nOpen: TMenuItem;
    nSaveAs: TMenuItem;
    sdVerticeSaver: TSaveDialog;
    sdArcsSaver: TSaveDialog;
    odVerticeOpener: TOpenDialog;
    odArcsOpener: TOpenDialog;
    procedure frmGraphEditorCreate(Sender: TObject);
    procedure frmGraphEditorClose(Sender: TObject; var Action: TCloseAction);
    procedure SetClickState(Sender: TObject);
    procedure imGraphCanvasClick(Sender: TObject);
    procedure nExitClick(Sender: TObject);
    procedure nClearClick(Sender: TObject);
    procedure nOpenClick(Sender: TObject);
    procedure nSaveClick(Sender: TObject);
    procedure nSaveAsClick(Sender: TObject);
    procedure nAboutClick(Sender: TObject);
  private
    State: TClickState; // Переменная состояния для работы с графом
    G: TGraph; // Граф для редактирования
    StartVertice: TPVertice; // Указатель на запомненную вершину
    wasPainted: Boolean; // Флаг о том, что необходимо перерисовать граф
    VerticesFileName, ArcsFileName: String; // Последние имена файлов

    function StartSearch(const G: TGraph; State: TClickState;
      v, u: Integer): Boolean;
    function OpenGraph(var fVertices: TVerFile; var fArcs: TArcFile): Boolean;
    procedure SaveGraph(var fVertices: TVerFile; var fArcs: TArcFile);

  const
    R = 40; // Радиус вершины графа

  end;

var
  frmGraphEditor: TfrmGraphEditor;

implementation

{$R *.dfm}

// Вспомогательная функция для вызова процедур поиска
function TfrmGraphEditor.StartSearch(const G: TGraph; State: TClickState;
  v, u: Integer): Boolean;
var
  Weights: TWeights; // Матрица весов
  Path: TStack; // Пройденный путь
  Vertice: TPVertice; // Указатель на вершину
  flag: Boolean;
begin
  ToWeightMatrix(G, Weights); // Преобразование в матрицу расстояний

  // Выбор алгоритма поиска
  case State of
    stDFS:
      DFS(Weights, v, u, Path);
    stBFS:
      BFS(Weights, v, u, Path);
    stDijkstra:
      Dijkstra(Weights, v, u, Path);
  end;

  // Результат о достижимости конечной вершины
  Result := not isEmpty(Path);

  // Цикл А1. Перекраска вершин пути
  flag := true;
  while not isEmpty(Path) do
  begin
    v := Pop(Path);
    GetByNumber(G, v, Vertice);
    if flag or isEmpty(Path) then
    begin
      Vertice.Design := dgEndPoint;
      flag := false;
    end
    else
      Vertice.Design := dgVisited;
  end; // Конец А1

end;

// Метод создания формы
procedure TfrmGraphEditor.frmGraphEditorCreate(Sender: TObject);
begin
  State := stNone; // Инициализация режима работы
  InitializeGraph(G); // Инициализация графа

  // Инициализация начальных имён файлов
  VerticesFileName := '';
  ArcsFileName := '';

  // Инициализация графических настроек
  with frmGraphEditor.imGraphCanvas.Canvas do
  begin
    Pen.Width := 3;
    Font.Size := 15;
    Font.Style := [fsBold];
    StartVertice := nil;
    wasPainted := false;
  end;
end;

// Метод закрытия формы
procedure TfrmGraphEditor.frmGraphEditorClose(Sender: TObject;
  var Action: TCloseAction);
begin
  DestroyGraph(G); // Освобождение занятой памяти
end;

// Метод получения переменной состояния через кнопки на панели
procedure TfrmGraphEditor.SetClickState(Sender: TObject);
var
  i: Integer; // Номер кнопки на панели
  Child: TControl; // Список контролов на панели
begin

  // Перерисовка в случае необходимости
  if wasPainted or (StartVertice <> nil) then
  begin
    RedrawGraph(imGraphCanvas, R, G, true);
    wasPainted := false;
  end;

  // Инициализация режима работы и начальной вершины
  StartVertice := nil;
  State := stNone;

  // Цикл А1. Перебор контролов панели
  for i := 0 to plFunctionsContainer.ControlCount - 1 do
  begin
    Child := plFunctionsContainer.Controls[i];
    if (Child as TSpeedButton).Down then
      State := TClickState(i);
  end; // Конец А1
end;

// Основной метод для редактирования графа
procedure TfrmGraphEditor.imGraphCanvasClick(Sender: TObject);
var
  Pos: TPoint; // Позиция курсора мыши
  Vertice: TPVertice; // Указатель на вершину
  isFound: Boolean; // Флаг о достижимости вершины при поиске
begin

  // Перерисовка графа
  if wasPainted then
  begin
    RedrawGraph(imGraphCanvas, R, G, wasPainted);
    wasPainted := false;
  end;

  // Перебор переменной состояния
  Pos := ScreenToClient(Mouse.CursorPos);
  case State of
    stAddVertice: // Добавление вершины
      AddVertice(G, Pos);
    stDeleteVertice: // Удаление вершины
      begin
        Centralize(G, Pos, R, Vertice);
        if Vertice <> nil then
          DeleteVertice(G, Vertice.Number);
      end;
    stAddArc, stDeleteArc, stDFS, stBFS, stDijkstra: // Действия по 2-м вершинам
      begin
        if StartVertice = nil then
        begin

          // Получение начальной вершины
          Centralize(G, Pos, R, StartVertice);
          if StartVertice <> nil then
            StartVertice.Design := dgActive;

        end // Конец if
        else
        begin
          Centralize(G, Pos, R, Vertice);
          if Vertice = nil then
            Exit;

          // Перебор переменной состояния
          case State of
            stAddArc: // Добавление ребра
              begin
                if not AreAdjacent(G, Vertice.Number, StartVertice.Number) then
                  AddArc(G, StartVertice.Number, Vertice.Number);
                StartVertice.Design := dgPassive;
              end;
            stDeleteArc: // Удаление ребра
              begin
                if AreAdjacent(G, StartVertice.Number, Vertice.Number) then
                  DeleteArc(G, StartVertice.Number, Vertice.Number);
                StartVertice.Design := dgPassive;
              end;
            stDFS, stBFS, stDijkstra: // Алгоритмы поиска
              begin
                isFound := StartSearch(G, State, StartVertice.Number,
                  Vertice.Number);
                if not isFound then
                  ShowMessage('Путь не найден.');
                wasPainted := true; // Флаг о необходимости перерисовки
              end;
          end;
          StartVertice := nil; // Сброс начальной вершины после обработки обеих
        end; // Конец case

      end; // Конец else
  end; // Конец case

  // Перерисовка графа
  if State <> stNone then
    RedrawGraph(imGraphCanvas, R, G);
end;

procedure TfrmGraphEditor.nOpenClick(Sender: TObject);
var
  fVertices: TVerFile;
  fArcs: TArcFile;
  isSuccess: Boolean;
begin
  odVerticeOpener.FileName := '';
  odArcsOpener.FileName := '';

  // Выбор файла с вершинами
  if odVerticeOpener.Execute then
  begin

    // Проверка корректности расширения
    if ExtractFileExt(odVerticeOpener.FileName) <> '.ver' then
    begin
      ShowMessage('Выбран файл с неверным расширением.');
      Exit;
    end;

    // Выбор файла с дугами
    if odArcsOpener.Execute then
    begin

      // Проверка корректности расширения
      if ExtractFileExt(odArcsOpener.FileName) <> '.arc' then
      begin
        ShowMessage('Выбран файл с неверным расширением.');
        Exit;
      end;

      // Инициализация графа
      DestroyGraph(G);
      InitializeGraph(G);

      // Подготовка файлов
      System.Assign(fVertices, odVerticeOpener.FileName);
      System.Assign(fArcs, odArcsOpener.FileName);
      Reset(fVertices);
      Reset(fArcs);

      // Чтение графа

      isSuccess := OpenGraph(fVertices, fArcs);
      // Обработка ошибки
      if not isSuccess then
      begin
        DestroyGraph(G);
        InitializeGraph(G);
        ShowMessage('Данные файлов некорректны.');
      end
      else
      begin
        VerticesFileName := odVerticeOpener.FileName;
        ArcsFileName := odArcsOpener.FileName;
      end;

      // Закрытие файлов
      CloseFile(fVertices);
      CloseFile(fArcs);

      // Перерисовка графа
      RedrawGraph(imGraphCanvas, R, G);
    end;

  end;

end;

procedure TfrmGraphEditor.nSaveAsClick(Sender: TObject);
begin

  sdVerticeSaver.FileName := '';
  sdArcsSaver.FileName := '';

  // Выбор файла с вершинами
  if not sdVerticeSaver.Execute then
    Exit;

  // Проверка корректности расширения
  if ExtractFileExt(sdVerticeSaver.FileName) <> '.ver' then
  begin
    ShowMessage('Выбран файл с неверным расширением.');
    Exit;
  end;

  // Выбор файла с дугами
  if not sdArcsSaver.Execute then
    Exit;

  // Проверка корректности расширения
  if ExtractFileExt(sdArcsSaver.FileName) <> '.arc' then
  begin
    ShowMessage('Выбран файл с неверным расширением.');
    Exit;
  end;

  // Сохранение путей к файлу и сохранение графа
  VerticesFileName := sdVerticeSaver.FileName;
  ArcsFileName := sdArcsSaver.FileName;
  nSaveClick(Sender);

end;

procedure TfrmGraphEditor.nSaveClick(Sender: TObject);
var
  fVertices: TVerFile;
  fArcs: TArcFile;
  isSuccess: Boolean;
begin

  // Переход к "сохранению как"
  if (VerticesFileName = '') or (ArcsFileName = '') then
  begin
    Self.nSaveAsClick(Sender);
    Exit
  end;

  // Подготовка файлов
  System.Assign(fVertices, VerticesFileName);
  System.Assign(fArcs, ArcsFileName);
  Rewrite(fVertices);
  Rewrite(fArcs);

  // Сохранение графа
  SaveGraph(fVertices, fArcs);

  // Закрытие файлов
  CloseFile(fVertices);
  CloseFile(fArcs);
end;

// Метод очистки холста
procedure TfrmGraphEditor.nAboutClick(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TfrmGraphEditor.nClearClick(Sender: TObject);
begin
  DestroyGraph(G);
  InitializeGraph(G);
  RedrawGraph(imGraphCanvas, R, G);
end;

// Метод выхода из программы
procedure TfrmGraphEditor.nExitClick(Sender: TObject);
begin
  Close;
end;

// Метод открытия графа из файла
function TfrmGraphEditor.OpenGraph(var fVertices: TVerFile;
  var fArcs: TArcFile): Boolean;
var
  Vertice: TPVertice;
  AdjVertice: TPAdjVertice;
  v: Integer;
begin

  // Цикл А1. Проход по файлу вершин
  Result := true;
  New(Vertice);
  New(AdjVertice);
  while Result and not Eof(fVertices) do
  begin

    // Чтение очередной вершины
    Read(fVertices, Vertice^);
    AddVertice(G, Vertice.Center);

    // Проверка корректности прочитанных вершины
    with Vertice^ do
    begin
      Result := Number = G.Tail.Number;
      Result := Result and (Center.X >= 0) and (Center.Y >= 0);
    end;

    // Цикл А2. Частичный проход по файлу рёбер
    v := 1;
    while Result and (v <= Vertice.Deg) do
    begin
      Result := not Eof(fArcs); // Проверка на недостаток соседей

      // Чтение очередного соседа
      if Result then
      begin
        Read(fArcs, AdjVertice^);
        AddArc(G, Vertice.Number, AdjVertice.Number);
        Inc(v);
        // Переход к следующему соседу
      end;
    end; // Конец А2

    Result := Result and (AdjVertice.Next = nil); // Проверка на избыток соседей

  end; // Конец А1

  Dispose(Vertice);
  Dispose(AdjVertice);
end;

// Метод сохранения графа в файл
procedure TfrmGraphEditor.SaveGraph(var fVertices: TVerFile;
  var fArcs: TArcFile);
var
  Vertice: TPVertice;
  AdjVertice: TPAdjVertice;
begin

  // Цикл А1. Проход по вершинам
  Vertice := G.Head;
  while Vertice <> nil do
  begin
    Write(fVertices, Vertice^);

    // Цикл А2. Проход по соседям
    AdjVertice := Vertice.Head;
    while AdjVertice <> nil do
    begin
      Write(fArcs, AdjVertice^);
      AdjVertice := AdjVertice.Next;
    end; // Конец А1
    Vertice := Vertice.Next;
  end; // Конец А2
end;

end.
