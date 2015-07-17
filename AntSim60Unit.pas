unit AntSim60Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, TeEngine, Series, BubbleCh, ExtCtrls, TeeProcs, Chart, Math;

const

  MAX_X          = 1000;
  MAX_Y          = 1000;
  MAX_TIME       = 10000;
  MAX_PATCHES    = 100;
  PATCH_RADIUS   = 30;
  NEST_RADIUS    = 50;
  TRAIL_STEPS    = 200;          //max. Länge eines Trails
  MAX_ANTS       = 10000;
  TWIST          = 0.2;          //p(Richtungsänderung)
  ANT_RADIUS     = 10;           //Wahrnehmungsradius

type
  TForm1 = class(TForm)
    CloseButton: TButton;
    RunButton: TButton;
    chart1: TChart;
    Series1: TBubbleSeries;
    Series2: TBubbleSeries;
    Series3: TBubbleSeries;
    StopButton: TButton;
    Chart2: TChart;
    Series4: TLineSeries;
    Chart3: TChart;
    Series5: TLineSeries;
    Chart4: TChart;
    Series6: TLineSeries;
    Series7: TLineSeries;
    Series8: TLineSeries;
    AddPatchButton: TButton;
    SaveButton: TButton;
    n_AntsEdit: TEdit;
    n_AntsLabel: TLabel;
    PaintFreqEdit: TEdit;
    PaintFreqLabel: TLabel;
    PatchesEdit: TEdit;
    PatchesLabel: TLabel;
    LoadingTimeLabel: TLabel;
    LoadingTimeEdit: TEdit;
    UnloadingTimeLabel: TLabel;
    UnloadingTimeEdit: TEdit;
    SpeedLabel: TLabel;
    SpeedEdit: TEdit;
    c_MarkLabel: TLabel;
    c_MarkEdit: TEdit;
    EvapLabel: TLabel;
    EvapEdit: TEdit;
    Nest_xEdit: TEdit;
    Nest_xLabel: TLabel;
    Nest_yLabel: TLabel;
    Nest_yEdit: TEdit;
    f_ScoutsLabel: TLabel;
    p_Max_ScoutEdit: TEdit;
    p_Inc_ScoutEdit: TEdit;
    p_BoredEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    PatchesCheckBox: TCheckBox;
    Label7: TLabel;
    Patch1Label: TLabel;
    Patch2Label: TLabel;
    Patch_yLabel: TLabel;
    Patch_xLabel: TLabel;
    Patch2_yEdit: TEdit;
    Patch2_xEdit: TEdit;
    Patch1_yEdit: TEdit;
    Patch1_xEdit: TEdit;
    Delay2Edit: TEdit;
    DelayLabel: TLabel;
    p_PlotChart: TChart;
    Series9: TLineSeries;
    PherCheckBox: TCheckBox;
    Label8: TLabel;
    Patch_QualityCheckBox: TCheckBox;
    Patch1_qEdit: TEdit;
    Patch2_qEdit: TEdit;
    Label9: TLabel;
    FeedBackCheckBox: TCheckBox;
    Label10: TLabel;
    CMaxEdit: TEdit;
    Label11: TLabel;
    flowEdit: TEdit;
    Label12: TLabel;
    Label13: TLabel;
    nEdit: TEdit;
    kEdit: TEdit;
    BidirectionalCheckBox: TCheckBox;
    degPatchCheckBox: TCheckBox;
    PatchLoadEdit: TEdit;
    Label3: TLabel;
    procedure RunButtonClick(Sender: TObject);        //Anwendung starten
    procedure PatchesCheckBoxClick(Sender: TObject);  //Patches zufällig?
    procedure PatchesEditChange(Sender: TObject);     //nicht zu viele Patches ?
    procedure AddPatchButtonClick(Sender: TObject);   //Patch hinzufügen
    procedure StopButtonClick(Sender: TObject);       //Programm anhalten
    procedure SaveButtonClick(Sender: TObject);       //Ergebnisse speichern
    procedure CloseButtonClick(Sender: TObject);      //Programm schließen
    procedure p_Max_ScoutEditChange(Sender: TObject);
    procedure p_Inc_ScoutEditChange(Sender: TObject);
    procedure Patch_QualityCheckBoxClick(Sender: TObject);
    procedure FeedBackCheckBoxClick(Sender: TObject);
    procedure degPatchCheckBoxClick(Sender: TObject);

  private
    { Private-Deklarationen}
  public
    { Public-Deklarationen}
  end;

  TNest = record
    x,y    : double; //Koordinaten
    radius : word;
    ants   : word;//Ameisen vor Ort (Unload nicht vergessen)
    end; //Nest

  TTrail = array[1..TRAIL_STEPS] of double;

  TNext_Trail = record
    x,y    : double;      //nächster Punkt auf dem Trail
    index  : byte;        //welcher Trail?
    end; //nächstliegender Trail aus der Sicht einer bestimmten Ameise

  TPatch = record
    x,y    : double;
    radius : word;
    ants   : word;        //Amesien vor Ort
    load   : double;      //Futtermenge
    trail  : TTrail;      //Pheromonkonzentrationen
    end; //Futterpatch

  TAnt = record //Ameise
    x,y,speed,
    motiv,                //Motivation,Begeisterung von der Futterquelle
    alpha,load : double; //Koordinaten, Geschwindigkeit und Bewegungswinkel,
    radius,          //Radius und momentane Ladung an Futter,
    patch_index,          //Patch, den die Ameise zur Zeit besucht
    patch_dist : word;    //und die Entfernung zum besagten Patch in Schritten.
    counter,              //Zeitzähler, für 'loading-' und 'unloading time'
    status     : byte;   //aktueller Zustand/Tätigkeit
    // 0 = home
    // 1 = scout
    // 2 = load
    // 3 = nestbound
    // 4 = unload
    // 5 = patchbound
    end; //eine Ameise und ihre Eigenschaften

  Procedure Simulate();
  Procedure ReadValues();                            //Parameter einlesen
  Procedure Initialize(var paint_time : word);       //Simulation starten
    Procedure SetNest(var s : TNest);                //Nest einsetzen
    Procedure SetPatch(index : word; var s : TPatch);//Futter einsetzen
    Procedure SetAnt(var s : TAnt);                  //Ameise einsetzen

  Procedure Move(var m : TAnt);                      //Aktionen der Ameisen
    Procedure Home(var h : TAnt);                    //rausgehen oder nicht?
    Procedure Scout(var s : TAnt);                   //Scouts bewegen
       Procedure Search(var s : TAnt);               //zufällige Bewegung
       Procedure HitTrail(index : word;
         var h : TAnt; var t : TNext_trail);         //Spur in der Nähe?
       Procedure EvalCon(index : word;
         var e : TAnt; var t : TNext_trail);         //Konzentration?
    Procedure Load(var l : TAnt);                    //Ladung aufnehmen
    Procedure Nestbound(var n : TAnt);               //Futter wegtragen
    Procedure Unload(var u : TAnt);                  //Ladung abgeben
    Procedure Patchbound(var p : TAnt);              //Auf der Spur laufen

  Procedure Go(var g : TAnt; dest_x,dest_y : double);//auf einen Punkt zu laufen
  Procedure PatchDist(patch : word; var p : TAnt);   //Entfernung zum Patch
  Procedure ChooseTrail(var c : TAnt);//Trail auswählen
  Procedure Evaporation(var trail : TTrail);         //Spur verfliegt
  Procedure DeletePatch(index : word);
  Procedure ReadCapWord(caption : string; var value : word);//Editierfeld lesen
  Procedure ReadCapDouble(caption : string; var value : double);//s.o.für double
  Procedure CheckDelay(time : word);                 //Patch erscheint?
  Procedure PGraph(p_max,p_inc : double);            //Plot p(c)

  Procedure Graph(time : word);                      //Graphik erstellen

  Procedure Save();                                  //Ergebnisse speichern

  Function Distance(ax,ay,bx,by : double): double;   //Distanz 2er Punkte
  Function Lot_x(ax,ay,bx,by,px,py:double) : double; //x(Oli'scher Schnittpunkt)
  Function Lot_y(ax,ay,bx,by,px,py:double) : double; //y(Oli'scher Schnittpunkt)
  Function Lot_denom(ax,ay,bx,by:double) : double;   //Nenner von Olivers Formel
  Function P_Follow(p_max,p_inc,c : double): double; //p(Ameise folgt dem Trail)

var
  Form1     : TForm1;
  Nest      : TNest;
  intake    : double;  //ins Nest eingetragenes Futter
  stop,add  : boolean; //Abfragevariablen für 'stop' und die 'add patch'-Button

  n_patches,        //Anzahl der Patches
  n_ants,           //Anzahl der Ameisen
  paint_freq,       //Zeitschritte, nach denen die Graphik aktualisiert wird
  loading_time,     //benötigte Zeit für das Aufnehmen der Ladung
  unloading_time,   //benötigte Zeit für das Ablegen der Ladung
  patch_delay,      //Zeitverzögerung für das Erscheinen von Patches
  patch_load,       //mittlere Nahrungsmenge am Patch
  speed : word;     //zurückgelegte Entfernung/Zeitschritt


  trail_evap,       //Anteil an Pheromon, der pro Zeitschritt verdunstet
  nest_x,nest_y,    //Nestkoordinaten
  patch1_q,
  patch2_q,         //Patchqualitäten
  patch1_x,
  patch1_y,
  patch2_x,
  patch2_y,         //Koordinaten für Patches
  move_sum,         //Summe aller gelaufenen Entfernungen
  c_mark,           //abgegebene Pheromonmenge bei einer Markierung
  c_max,            //Maximale Pheromonkonzetration bei Qualität = 1
  p_max_scout,      //Die Wahrscheinlichkeit einem Trail zu folgen ist eine..
  p_inc_scout,      //..Funktion der Pheromonkonzentration an der jeweiligen..
                    //..Stelle. Es handelt sich dabei um eine begrenzte Wachs..
                    //..tumsfunktion mit einer horizontalen Asymptote (p_max)..
                    //..und einer Steigung (p_inc). Beide Parameter können in..
                    //..Abhängigkeit vom jew. Status festgelegt werden.
  f_scouts,         //Anteil an Scouts unter den aktiven Tieren
  k,n,              //Parameter für sigmoide p-Funktion nach Deneubourg
  int_mean_old,     //intake Gleitmittelwert für Graphik
  flow : double;    //Wahrscheinlichkeit, das ein Tier in einem Zeitschritt..
                    //..das Nest verlässt.

  Patches   : array[1..MAX_PATCHES] of TPatch; //alle Futterquellen
  Ants      : array[1..MAX_ANTS] of TAnt;      //alle Ameisen

  output    : textfile;                        //Textdatei zum Daten ablegen

implementation

{$R *.DFM}

//Funktionen____________________________________________________________________
//______________________________________________________________________________

Function Distance(ax,ay,bx,by:double): double;   //Entfernungen
  begin
  result := sqrt(sqr(ax-bx) + sqr(ay-by));
  end; //Koordinaten 2er Punkte -> Entfernung

Function Lot_x(ax,ay,bx,by,px,py:double) : double; //x(Oli'scher Schnittpunkt)
  begin
  result := (ax-((bx-ax)*(bx*ax-sqr(ax)+px*(-bx+ax)-py*by+py*ay+by*ay-sqr(ay)))
    /(sqr(bx)-2*bx*ax+sqr(ax)+sqr(by-ay)));
  end; //Olivers Formel: Koordinaten 3er Punkte -> x-Wert des Schnittpunktes..
       //..der Geraden AB mit dem Lot von C auf selbige Gerade.

Function Lot_y(ax,ay,bx,by,px,py:double) : double; //y(Oli'scher Schnittpunkt)
  begin
  result := (ay-((by-ay)*(bx*ax-sqr(ax)+px*(-bx+ax)-py*by+py*ay+by*ay-sqr(ay)))
    /(sqr(bx)-2*bx*ax+sqr(ax)+sqr(by-ay)));
  end; //Olivers Formel: Koordinaten 3er Punkte -> x-Wert des Schnittpunktes..
       //..der Geraden AB mit dem Lot von C auf selbige Gerade.

Function Lot_denom(ax,ay,bx,by:double) : double; //Nenner von Olis Formel
  begin
  result := (sqr(bx)-2*bx*ax+sqr(ax)+sqr(by-ay));
  end; //wenn sich die Ameise genau auf der Geraden befindet, ergibt der Nen-..
       //..ner 0, das vorher muss geprüft werden.

Function P_Follow(p_max,p_inc,c : double): double; //p(Ameise folgt dem Trail)
  begin
  result := p_max * (1- exp(- p_inc * c));
  end; //Wahrscheinlichkeit in Abhängigkeit von der Konzentration


//Simulation____________________________________________________________________

Procedure Simulate();
  var time, paint_time, ant, patch : word;    //Zählvariablen
  begin
  Initialize(paint_time);               //Objekte einsetzen
  for time:=1 to MAX_TIME do            //Zeitschleife
    begin
    CheckDelay(time);
    for ant:=1 to n_ants do             //alle Ameisen..
      begin
      Move(Ants[ant]);                    //Aktionen der Ameisen
      if Ants[ant].counter > 0 then       //Zeitzähler prüfen
        dec(Ants[ant].counter);
      end; //for ant:=...
    if paint_time = 0 then              //Graphik erzeugen
      begin
      Graph(time);                        //Punkte zeichnen
      application.processmessages;        //Auf neue Eingaben prüfen
      paint_time := paint_freq;           //Zeitzähler zurücksetzen
      end; //if paint_time...
    for patch:=1 to n_patches do        //alle Trails...
      begin
      Evaporation(Patches[patch].trail);  //Trail verdunstet
      if (Patches[patch].load = 0) and (sum(Patches[patch].trail) = 0) then
        begin
        DeletePatch(patch);
        end;
      end; //for patch:=...
    paint_time := paint_time - 1;        //Zeit herunterzählen
    if stop=true then break;             //Abbruch?
    if add=true then                     //wurde 'add patch' angeklickt?
      begin
      inc(n_patches);                      //Anzahl der Patches erhöhen
      SetPatch(0,Patches[n_patches]);      //neuen Patch generieren
      add := false;                        //Schalter wieder deaktivieren
      end; //if add..
    end; //for time:=...
  Form1.StopButton.Visible  := false;
  Form1.SaveButton.visible  := true;
  Form1.CloseButton.Visible := true;
  end;

//______________________________________________________________________________

procedure TForm1.RunButtonClick(Sender: TObject);
  begin
  randomize;                            //Zufallsgenerator
  ReadValues();                         //Parameter einlesen
  Simulate();
  end; //procedure

procedure TForm1.PatchesCheckBoxClick(Sender: TObject); //Patches zufällig?
  begin
  if Form1.AddPatchButton.Visible = true then //d.h. Patches vorher zufällig
    begin
    Form1.AddPatchButton.Visible := false;
    if not (Form1.PatchesEdit.text = '1') or (Form1.PatchesEdit.text = '2') then
    Form1.PatchesEdit.text := '2';     //nicht mehr als 2 Patches
    Form1.Patch1Label.Visible    := true;
    Form1.Patch_xLabel.Visible   := true;
    Form1.Patch_yLabel.Visible   := true;
    Form1.Patch1_xEdit.Visible   := true;
    Form1.Patch1_yEdit.Visible   := true;
    Form1.Label9.Visible         := true;
    Form1.Patch1_qEdit.Visible   := true;
    if Form1.PatchesEdit.text = '2' then
      begin
      Form1.Patch2_xEdit.Visible   := true;
      Form1.Patch2_yEdit.Visible   := true;
      Form1.Patch2Label.Visible    := true;
      Form1.DelayLabel.visible     := true;
      Form1.Delay2Edit.Visible     := true;
      Form1.Patch2_qEdit.Visible   := true;
      end;
    end //if Form1.Add...
  else
    begin
    Form1.AddPatchButton.Visible := true; //Button einblenden
    Form1.Patch1Label.Visible    := false;
    Form1.Patch2Label.Visible    := false;
    Form1.Patch_xLabel.Visible   := false;
    Form1.Patch_yLabel.Visible   := false;
    Form1.Patch1_xEdit.Visible   := false;
    Form1.Patch1_yEdit.Visible   := false;
    Form1.Patch2_xEdit.Visible   := false;
    Form1.Patch2_yEdit.Visible   := false;
    Form1.DelayLabel.visible     := false;
    Form1.Delay2Edit.Visible     := false;
    Form1.Label9.Visible         := false;
    Form1.Patch1_qEdit.Visible   := false;
    Form1.Patch2_qEdit.Visible   := false;
    end; //else...
  end;

procedure TForm1.PatchesEditChange(Sender: TObject); //nicht mehr als 2 Patches
  begin
  if Form1.PatchesCheckBox.checked = false then
    begin
    if not (Form1.PatchesEdit.text = '1') or (Form1.PatchesEdit.text = '2') then
    Form1.PatchesEdit.text := '2';     //nicht mehr als 2 Patches
    if Form1.PatchesEdit.text = '2' then
      begin
      Form1.Patch2_xEdit.Visible   := true;
      Form1.Patch2_yEdit.Visible   := true;
      Form1.Patch2Label.Visible    := true;
      Form1.DelayLabel.visible     := true;
      Form1.Delay2Edit.Visible     := true;
      Form1.Patch2_qEdit.Visible   := true;
      end; //if Delay...
    end; //if CheckBox...
  end;

procedure TForm1.Patch_QualityCheckBoxClick(Sender: TObject);
  begin
  if Form1.Patch_QualityCheckBox.checked = true then
    begin
    Form1.Patch1_qEdit.enabled := true;
    Form1.Patch2_qEdit.enabled := true;
    end
  else
    begin
    Form1.Patch1_qEdit.enabled := false;
    Form1.Patch2_qEdit.enabled := false;
    end;
  end;

procedure TForm1.FeedBackCheckBoxClick(Sender: TObject);
  begin
  if Form1.FeedBackCheckBox.checked = true then
    begin
    Form1.Label10.visible := true;
    Form1.CMaxEdit.visible := true;
    end
  else
    begin
    Form1.Label10.visible := false;
    Form1.CMaxEdit.visible := false;
    end;
  end;

procedure TForm1.degPatchCheckBoxClick(Sender: TObject);
  begin
  if Form1.degPatchCheckBox.checked = true then
    begin
    Form1.Label3.visible := true;
    Form1.PatchLoadEdit.visible := true;
    end
  else
    begin
    Form1.Label3.visible := false;
    Form1.PatchLoadEdit.visible := false;
    end;
  end;

procedure TForm1.AddPatchButtonClick(Sender: TObject); //neuen Patch hinzufügen
  begin
  add := true;
  end;


procedure TForm1.StopButtonClick(Sender: TObject); //Programm anhalten
  begin
  Form1.SaveButton.visible  := true;   //Save und Closebutton ausblenden
  Form1.CloseButton.Visible := true;
  Form1.StopButton.Visible  := false;
  Form1.AddPatchButton.enabled := false;
  stop := true;
  end;

procedure TForm1.SaveButtonClick(Sender: TObject); //Daten in Textfile speichern
  begin
  Save();
  end;

procedure TForm1.CloseButtonClick(Sender: TObject); //Programm schließen
  begin
  close;
  end;

//Initialisierung_______________________________________________________________

Procedure ReadValues(); //Parameter einlesen
  begin
  ReadCapWord(Form1.n_AntsEdit.text,n_ants);
  ReadCapWord(Form1.PaintFreqEdit.text,paint_freq);
  ReadCapWord(Form1.PatchesEdit.text,n_patches);
  ReadCapWord(Form1.LoadingTimeEdit.text,loading_time);
  ReadCapWord(Form1.UnloadingTimeEdit.text,unloading_time);
  ReadCapWord(Form1.SpeedEdit.text,speed);
  ReadCapWord(Form1.PatchLoadEdit.text,patch_load);
  ReadCapDouble(Form1.c_MarkEdit.text,c_mark);
  ReadCapDouble(Form1.flowEdit.text,flow);
  if Form1.FeedBackCheckBox.checked = true then
    begin
    ReadCapDouble(Form1.cMaxEdit.text ,c_max);
    end;
  if Form1.PatchesCheckBox.checked = false then //nur, wenn Patches nicht zu-..
    begin                                       //..fällig positioniert werden.
    ReadCapWord(Form1.Delay2Edit.text ,patch_delay);
    if patch_delay > 0 then n_patches := 1;     //hier nur mit einem anfangen
    end;
  ReadCapDouble(Form1.Patch1_qEdit.text ,patch1_q);
  ReadCapDouble(Form1.Patch2_qEdit.text ,patch2_q);
  ReadCapDouble(Form1.EvapEdit.text,trail_evap);
  ReadCapDouble(Form1.Nest_xEdit.text,nest_x);
  ReadCapDouble(Form1.Nest_yEdit.text,nest_y);
  ReadCapDouble(Form1.Patch1_xEdit.text,patch1_x);
  ReadCapDouble(Form1.Patch1_yEdit.text,patch1_y);
  ReadCapDouble(Form1.Patch2_xEdit.text,patch2_x);
  ReadCapDouble(Form1.Patch2_yEdit.text,patch2_y);
  ReadCapDouble(Form1.p_Max_ScoutEdit.text,p_max_scout);
  ReadCapDouble(Form1.p_Inc_ScoutEdit.text,p_inc_scout);
  ReadCapDouble(Form1.p_BoredEdit.text,f_scouts);
  ReadCapDouble(Form1.nEdit.text,n);
  ReadCapDouble(Form1.kEdit.text,k);
  end; //diese Prozedur liest die Parameter, die in die Editierfenster einge-..
       //..geben wurden. All diese Parameter sind oben als globale Variablen..
       //..deklariert.

Procedure Initialize(var paint_time : word); //Objekte einsetzen
  var patch,ant : word;
  begin
  Form1.SaveButton.visible  := false;   //Save und Closebutton ausblenden
  Form1.CloseButton.Visible := false;
  Form1.StopButton.visible  := true;
  Form1.AddPatchButton.enabled := true;
  stop := false;               //Abbruchkriterium
  add  := false;               //Patch hinzufügen
  paint_time := 0;             //Zähler für die Graphikausgabe
  intake := 0;                 //Futtereintrag
  move_sum := 0;               //Kostenvariable Bewegung
  Form1.series2.clear;         //evtl. alte Graphiken löschen
  Form1.series3.clear;
  Form1.series4.clear;
  Form1.series5.clear;
  Form1.series6.clear;
  Form1.series7.clear;
  Form1.series8.clear;
  PGraph(p_max_scout,p_inc_scout);
  SetNest(Nest);               //Nest erzeugen
  for patch:=1 to n_patches do //alle Patches erzeugen
    begin
    SetPatch(patch,Patches[patch]);
    end; //for patch:=...
  for ant:=1 to n_ants do      //alle Ameisen erzeugen
    begin                                          
    SetAnt(Ants[ant]);
    end; //for ant:=...
  end; //Alle Variablen werden auf ihre Startwerte gesetzt, Nest, Futter-..
       //quellen und Ameisen werden erzeugt.

Procedure SetNest(var s : TNest); //Nest erzeugen
  begin
  s.x      := nest_x;        //Koordinaten des Nestes, werden im Editierfen-..
  s.y      := nest_y;        //..ster festgelegt.
  s.radius := NEST_RADIUS;   //der Radius ist konstant.
  end; //procedure

Procedure SetPatch(index : word; var s : TPatch); //Futterquelle erzeugen
  var
  i : word;
  begin
  if Form1.PatchesCheckBox.checked = true then //Patches zufällig verteilen?
    begin
    s.x := random*MAX_X;     //Die Positionierung der Futterquelle erfolgt..
    s.y := random*MAX_Y;     //..hier zufällig
    s.load := patch_load;
    end //if CheckBox...
  else
    begin
    if index = 1 then  //patch1
      begin
      s.x := patch1_x;
      s.y := patch1_y;
      s.load := patch1_q*patch_load;
      end  //if index...
    else               //patch2
      begin
      s.x := patch2_x;
      s.y := patch2_y;
      s.load := patch2_q*patch_load;
      end
    end; //else...
  s.radius := PATCH_RADIUS;     //Der Radius ist konstant.
  s.ants   := 0;                //keine Ameisen vor Ort
  for i:=1 to TRAIL_STEPS do    //alle Abschnitte auf dem zugehörigen Trail:
    begin
    s.trail[i] := 0;              //noch kein Pheromon vorhanden
    end; //for i:=1..
  end; //procedure

Procedure SetAnt(var s : TAnt); //Ameise erzeugen
  begin
  s.x       := Nest.x;      //Zu beginn der Simulation befinden sich alle..
  s.y       := Nest.y;      //..Ameisen im Nest.
  s.speed   := speed;       //wird in einem Editierfenster festgelegt.
  s.alpha   := 2*pi*random; //die Laufrichtung ist zu Beginn zufällig
  s.radius  := ANT_RADIUS;  //der Wahrnehmungsradius ist konstant
  s.load    := 0;           //noch keine Ladung
  s.counter := 0;           //Zeitzähler zurückgesetzt
  s.status  := 0;           //,da die Ameise ja noch im Nest ist.
  end; //procedure

//Tätigkeiten___________________________________________________________________

Procedure Move(var m : TAnt); //Was tut die Ameise?
  begin
  if m.status = 0 then Home(m);        //je nachdem, welchen Wert die Status-..
  if m.status = 1 then Scout(m);       //..variable eiener Ameise hat, wird..
  if m.status = 2 then Load(m);        //..an eine bestimmte Tätigkeitsproze-..
  if m.status = 3 then Nestbound(m);   //..dur übergeben.
  if m.status = 4 then Unload(m);
  if m.status = 5 then Patchbound(m);
  end; //procedure

Procedure Home(var h : TAnt);//0
  begin
  h.x       := Nest.x;                           //Ameise ist im Nest
  h.y       := Nest.y;
  if flow > random then
    begin                                        //..neue Futterquellen suchen?
    ChooseTrail(h);                              //Trail folgen?
    end; //if (h.status...
  end; //Die Prozedur prüft, ob eine Ameise von einem Trail angelockt wird,..
       //.. spontan das Nest verlässt, um Nahrung zu suchen oder im Nest bleibt.

Procedure Scout(var s : TAnt);//1
  var
  next_trail : TNext_trail;             //der nächstliegende Trail
  patch : word;                         //Zählvariable
  begin
  s.patch_index := 0;                   //noch kein Patch ausgewählt
  Search(s);                            //Bewegung im Raum
  for patch:=1 to n_patches do          //Schleife über alle Patches
    begin
    if (Distance(s.x,s.y,Patches[patch].x,Patches[patch].y) //Patch gefunden?
      < Patches[patch].radius) and (Patches[patch].load > 0) then
      begin
      s.patch_index := patch;                         //index anpassen
      s.status := 2;                                  //Ameise beginnt zu laden
      s.counter := loading_time;                      //Zeit wird gezählt
      Patches[patch].ants := Patches[patch].ants + 1; //Ameisenzahl
      end; //if Distance...
    if s.patch_index = 0 then                              //Trail gefunden?
      begin
      HitTrail(patch,s,next_trail);                   //Trail gefunden?
      EvalCon(patch,s,next_trail);                    //Trail stark genug?
      end;//if s.patch_index...
    end;//for patch:=1...
  end; //Diese Prozedur bewegt die Ameise und überprüft, ob sie dabei auf Pat-..
       //..ches oder die dazugehörigen Trails gestoßen ist.

Procedure Load(var l : TAnt);//2
  begin
  if l.counter = 0 then                //fertig geladen?
    begin
    l.status     := 3;                 //zum Nest laufen
    l.patch_dist := 0;                 //Dinstanz zum Patch
    l.motiv      := c_mark;
    if Patches[l.patch_index].load > 0 then
      begin
      l.load := 1;                     //Ladung aufnehmen
      if Form1.degPatchCheckBox.Checked = true then
        Patches[l.patch_index].load := Patches[l.patch_index].load - 1;
      end
    else
      begin
      l.status := 1;
      end;
    if Form1.PherCheckBox.checked = true then
      begin
      l.motiv := l.motiv*exp(- 0.01*Distance(Patches[l.patch_index].x,
      Patches[l.patch_index].y,Nest.x,Nest.y));
      end; //Markieren abhängig von der Entfernung?
    if Form1.Patch_QualityCheckbox.checked = true then
      l.motiv := l.motiv*Patches[l.patch_index].load; //...oder der Qualität?
    dec(Patches[l.patch_index].ants);  //eine Ameise weniger am Patch
    end; //if l.counter...
  end; //Die Prozedur prüft, ob eine Ameise lange genug am Patch war und..
       //..schickt sie dann auf den Rückweg. Wenn erwünscht wird die Motiva-..
       //..tion der Ameise an Entfernung und Qualitätsfaktor des Patches ange-..
       //..passt, von diesem Motivationswert hängt dann die Stärke der Mar-..
       //..kierung ab.

Procedure Nestbound(var n : TAnt);//3
  begin
  if not (Distance(n.x,n.y,Nest.x,Nest.y) < n.radius) then //Nest erreicht?
    begin //nein, dann:
    Go(n,Nest.x,Nest.y);         //Richtung Nest bewegen
    inc(n.patch_dist);           //neue Position auf dem Trail
    Patches[n.patch_index].trail[n.patch_dist]
    := Patches[n.patch_index].trail[n.patch_dist] + n.motiv; //Trail markieren
    if (Form1.FeedBackCheckBox.checked = true)
    and (Patches[n.patch_index].trail[n.patch_dist] > c_max*n.motiv) then
      Patches[n.patch_index].trail[n.patch_dist] := c_max*n.motiv;
    end //if not (Dinstance...
  else    //ja, Nest erreicht:
    begin
    n.x := Nest.x;                           //Ameise genau ins Nest setzen,..
    n.y := Nest.y;                           //..um Komplikationen zu vermeiden.
    Patches[n.patch_index].trail[n.patch_dist]
    := Patches[n.patch_index].trail[n.patch_dist] + n.motiv; //letzte Markierung
    if (Form1.FeedBackCheckBox.checked = true)
    and (Patches[n.patch_index].trail[n.patch_dist] > c_max*n.motiv) then
      Patches[n.patch_index].trail[n.patch_dist] := c_max*n.motiv;
    n.status := 4;                           //Entladen
    n.counter := unloading_time;             //Zähler einstellen
    end; //else...
  end; //Die Prozedur bewegt eine Ameise zum Nest, lässt sie dabei markieren..
       //..und ändert ihren Status in 'unload', wenn sie das Nest erreicht hat.

Procedure Unload(var u : TAnt);//4
  begin
  if u.counter = 0 then   //nötige Zeit verstrichen?
    begin
    intake   := intake + u.load; //Ladung abgeben
    u.load   := 0;               //eigene Ladung wieder auf 0 setzen
    u.patch_index := 0;          //kein Memory-Effect
    ChooseTrail(u);              //wieder auf den Trail?
    end; //if u.counter...
  end;   //Ist die nötige Zeit vergangen, entläd diese Prozedur die Ameise und..
         //..prüft, ob sie zum Trail zurückkehrt oder im Nest bleibt.

Procedure Patchbound(var p : TAnt);//5
  begin
  if not (Distance(p.x,p.y,Patches[p.patch_index].x,Patches[p.patch_index].y)
    < Patches[p.patch_index].radius) then     //schon angekommen?
    begin //nein, dann:
    if Form1.BidirectionalCheckBox.checked = true then //bidir. trail laying?
      begin
      PatchDist(p.patch_index,p);
      p.motiv := 1; //Patches[p.patch_index].trail[p.patch_dist];            //______________
      Patches[p.patch_index].trail[p.patch_dist]
      := Patches[p.patch_index].trail[p.patch_dist] + p.motiv;
      if (Form1.FeedBackCheckBox.checked = true)
      and (Patches[p.patch_index].trail[p.patch_dist] > c_max*p.motiv) then
        Patches[p.patch_index].trail[p.patch_dist] := c_max*p.motiv;
      end;
    Go(p,Patches[p.patch_index].x,Patches[p.patch_index].y); //zum Futter laufen
    end //if not...
  else //angekommen, dann:
    begin
    p.status := 2;                    //Patch erreicht, beladen beginnen
    p.counter := loading_time;        //Zähler eingestellt
    inc(Patches[p.patch_index].ants); //mehr Ameisen am Patch
    end; //else...
  end; //Eine Ameise wird den Trail entlang Richtung Patch bewegt, hat sie..
       //..diesen erreicht, so beginnt sie mit dem beladen.

//allgemeine Prozesse___________________________________________________________

Procedure Go(var g : TAnt; dest_x,dest_y : double); //auf einen Punkt zu laufen
  begin
  g.speed := SPEED;
  if not (sqrt(sqr(g.x-dest_x) + sqr(g.y-dest_y)) = 0) then //div 0 vermeiden
    begin
    g.x := g.x-(g.speed*(g.x-dest_x))/sqrt(sqr(g.x-dest_x)+sqr(g.y-dest_y));
    g.y := g.y-(g.speed*(g.y-dest_y))/sqrt(sqr(g.x-dest_x)+sqr(g.y-dest_y));
    end
  else                                                              
    if g.x = dest_x then
      if g.y < dest_y then g.y := g.y + g.speed
      else                 g.y := g.y - g.speed
    else
      if g.x < dest_x then g.x := g.x + g.speed
      else                 g.x := g.x - g.speed;
  move_sum := move_sum+distance(g.x,g.y,dest_x,dest_y);
  end; //Ameise, Zielpunkt -> Ameise mit neuen Koordinaten

Procedure PatchDist(patch : word; var p : TAnt); //Enferung zum Patch berechnen
  begin
  p.patch_dist := trunc((Distance(p.x,p.y,
  Patches[patch].x,Patches[patch].y)+1)/SPEED);
  end; //Nummer des Patches, Ameise -> Distanz zum Patch in SCHRITTEN (ent-..
       //..spricht Feld in dem Array, in dem die Pheromkonzentrationen gespei-..
       //..werden).

Procedure ChooseTrail(var c : TAnt); //Trail auswählen
  var
  i,j     : word; //2 Zählvariablen für 2 Schleifen über alle Patches
  ran,p,sum,conc : double; //Zwischenwerte
  term    : array[1..MAX_PATCHES] of double;
  begin
  sum := 0;             //Summe der Wahrscheinlichkeiten
  p := 0;               //Summenvariable für die relativen Wahrscheinlichkeiten
  conc := 0;              //Abfragevariable, wird größer 0 wenn Spur vorhanden
  for i:=1 to n_patches do //1.Schleife, Zwischenwerte berechnen
    begin
    PatchDist(i,c);                         //aktuelle Entfernung
    if Patches[i].trail[c.patch_dist] > 0 then //sonst hat auch ein leerer.. 
      term[i] := Power((k + Patches[i].trail[c.patch_dist]),n)//..Trail p > 0
    else term[i] := 0;
    sum := sum + term[i];                  //Summe berechnen
    conc := conc + Patches[i].trail[c.patch_dist];
    end;  //for i:=...
  if (conc > 0) and (f_scouts < random) then  //wenn alle Trails stark sind...
    begin
    ran := random;                         //eine Zufallszahl ziehen
    j   := 0;                              //Zählvariable zurücksetzen
    while j < n_patches do                 //Erwählen eines Trails
      begin
      j := j+1;                            //In dieser Schleife werden die..
      PatchDist(j,c);                      //..relativen Wahrsch. der einzel-..
      p := p + term[j]/sum;                //..nen Patches/Trail aufaddiert..
      if p > ran then                      //..und in jedem Schritt mit einer..
        begin                              //..Zufallszahl(ran) vergleicht.
        c.patch_index := j;
        c.status := 5;
        j := n_patches;
        end;   //if p...
      end; //for j:=...
    end //if (sum...
  else c.status := 1;                      //ansonsten geht die Ameise Scouten
  end;  //Zunächst wird geprüftm ob eine Ameise überhaupt irgend einem Trail..
        //..folgen will. Wenn ja, wird sie mit Hilfe der relativen Wahrschein-..
        //..lichkeiten einem bestimmten Trail zugeordnet.

Procedure Evaporation(var trail : TTrail); //Trail verdunsten
  var j : word;
  begin
  for j:=1 to TRAIL_STEPS do
    begin
    trail[j] := trail[j]*(1-trail_evap);
    if trail[j] < 0.1 then trail[j] := 0;
    end;
  end; //Alle Schritte auf dem Trail werden durchgegangen und die neuen Kon-..
       //..zentrationen werden berechnet.

Procedure DeletePatch(index : word);
  var patch, ant : word;
  begin
  for patch:=index to (MAX_PATCHES-1) do
    begin
    Patches[patch] := Patches[patch+1];
    end;
  for ant:=1 to n_ants do
    begin
    if Ants[ant].patch_index = index then
      begin
      Ants[ant].status := 1;
      Ants[ant].patch_index  := 0;
      end;
    if Ants[ant].patch_index > index then
      dec(Ants[ant].patch_index);
    end;
  dec(n_patches);
  end;

Procedure ReadCapWord(caption : string; var value : word); //parameter lesen
  var code : integer; //Fehlercode für "val"
  begin
  val(caption,value,code);
  end; //Ein Editierfenstereintrag wird als 'word'-Variable eingelesen

Procedure ReadCapDouble(caption : string; var value : double); //parameter lesen
  var code : integer;  //Fehlercode for "val"
  begin
  val(caption,value,code);
  end; //Ein Editierfenstereintrag wird als 'double'-Variable eingelesen

Procedure CheckDelay(time : word); //neuer Patch erscheint?
  begin
  if (Form1.PatchesEdit.text = '2') and (time = patch_delay) then
    begin
    inc(n_patches);
    SetPatch(2,Patches[n_patches]);
    end;
  end;

Procedure PGraph(p_max,p_inc : double);
  var c,p : double;  //Konzentration,Wahrscheinlichkeit
  begin
  Form1.Series9.clear;
  c := 0;
  p := 0;
  if not (p_inc = 0) then
    begin
    while p < p_max*0.99 do
      begin
      p := P_Follow(p_max,p_inc,c);
      Form1.Series9.AddXY(c,p,'',clred);
      c := c + p_inc*0.1;
      end;
    end;
  end;  

//Unterprozeduren_______________________________________________________________

Procedure Search(var s : TAnt); //Fläche absuchen
  begin
  s.speed := SPEED;
  s.alpha := s.alpha + 2*TWIST*pi*(random-0.5);  //Richtung
  s.x := s.x+s.speed*cos(s.alpha);               //neue Koordinaten
  s.y := s.y+s.speed*sin(s.alpha);
  if s.x > MAX_X then s.x := MAX_X;              //am Rand?
  if s.x < 0     then s.x := 0;
  if s.y > MAX_Y then s.y := MAX_Y;
  if s.y < 0     then s.y := 0;
  end; //eine Ameise bewegt sich im Raum und ändert zufällig die Richtung. Bei..
       //..Überschreiten der Begrenzung wird auf den Grenzwert zurückgesetzt.

Procedure HitTrail(index : word; var h : TAnt; var t : TNext_trail);
  begin
  if not(Lot_denom(Nest.x,Nest.y,Patches[index].x,Patches[index].y) = 0) then
    begin  //Nenner=0?
    t.x := Lot_x(Nest.x,Nest.y,Patches[index].x,Patches[index].y,h.x,h.y);
    t.y := Lot_y(Nest.x,Nest.y,Patches[index].x,Patches[index].y,h.x,h.y);
    end //Die Koordinaten des Oli'schen Punktes werden berechnet..
  else
    begin
    t.x := h.x; //falls Ameise genau auf der Linie und Nenner = 0
    t.y := h.y;
    end;
  end; //Berechnet den nächstliegenden Punkt/das Lot auf einem Trail für eine..
       //..Ameise.

Procedure EvalCon(index : word; var e : TAnt; var t : TNext_trail);//Dist.und c?
  begin
  PatchDist(index,e);  //Entferung zum Patch?
  if (Distance(e.x,e.y,Patches[index].x,Patches[index].y)//hinter dem Nest?
    < Distance(Nest.x,Nest.y,Patches[index].x,Patches[index].y)
    - Nest.radius)
    and (Distance(e.x,e.y,Nest.x,Nest.y)                 //hinter dem Patch?
    < Distance(e.x,e.y,Patches[index].x,Patches[index].y))
    and (Distance(e.x,e.y,t.x,t.y) < e.radius)           //Entfernung zum Trail?
    and (P_Follow(P_MAX_SCOUT,P_INC_SCOUT,Patches[index].trail[e.patch_dist])
    > random) then                                       //genug Pheromon?
    begin
    e.patch_index := index;  //Patch auswählen
    e.status := 5;           //zum Patch bewegen
    end; //end if
  end; //Diese Prozedur prüft, ob sich eine Ameise auf der Gerade zwischen dem..
       //..NEst und einem Patch befindet. Wenn ja, und wenn die Wahrschein-..
       //..lichkeit, diesem Trail zu folgen, hoch ist, folgt sie dem Trail.

//______________________________________________________________________________

Procedure Graph(time : word); //wir malen...
  var patch, ant : word;
  begin
  if time = 1 then int_mean_old := 0;
  Form1.series1.clear;                                    //alte Ameisen löschen
  for ant:=1 to N_ANTS do                                 //Ameisen einzeichnen
    begin
    Form1.series1.AddBubble(Ants[ant].x,Ants[ant].y,Ants[ant].radius,'',clred);
    end;
  for patch:=1 to N_PATCHES do                            //Patches einzeichnen
    begin
    if Patches[patch].load > 0 then
      Form1.series2.AddBubble(Patches[patch].x,Patches[patch].y,
      Patches[patch].radius,'P',clgreen)
    else Form1.series2.clear;
    end;
  Form1.Series3.AddBubble(Nest.x,Nest.y,Nest.radius,'',clblack);//Nest -"-
  Form1.Series4.AddXY(time,(intake/(n_ants*time+int_mean_old)),'',clred);
  int_mean_old := intake/(n_ants*time);
  Form1.Series5.AddXY(time,Patches[1].ants,'',clred);     //Ameisen Patch 1
  Form1.Series7.AddXY(time,Patches[1].trail[1],'',clred); //Trail 1
  if n_patches > 1 then
    begin
    Form1.Series6.AddXY(time,Patches[2].ants,'',clgreen); //Ameisen Patch 2
    Form1.Series8.AddXY(time,Patches[2].trail[1],'',clgreen);//Trail 2
    end;
  end; //Diese Prozedur zeichnet die aktuellen Positionen aller Objekte in die..
       //..Landschaft ein und aktualisiert alle Graphiken.

//______________________________________________________________________________

Procedure Save(); //Ergebnisse speichern
  var patch : word;
  begin
  assignfile(output,'output.txt');                    //Datei zuordnen
  append(output);                                     //Datei öffnen
  writeln(output,'parameters:');                      //vorgegebene Parameter
  writeln(output,'MAX_TIME:',MAX_TIME);
  writeln(output,'n_patches:',n_patches);
  writeln(output,'PATCH_RADIUS:',PATCH_RADIUS);
  writeln(output,'LOADING_TIME:',LOADING_TIME);
  writeln(output,'TRAIL_EVAP:',TRAIL_EVAP);
  writeln(output,'NEST_RADIUS:',NEST_RADIUS);
  writeln(output,'UNLOADING_TIME:',UNLOADING_TIME);
  writeln(output,'N_ANTS:',N_ANTS);
  writeln(output,'SPEED:',SPEED);
  writeln(output,'TWIST:',TWIST);
  writeln(output,'ANT_RADIUS:',ANT_RADIUS);
  writeln(output,'C_MARK:',C_MARK);
  writeln(output,'P_MAX_SCOUT:',P_MAX_SCOUT);
  writeln(output,'P_INC_SCOUT:',P_INC_SCOUT);
  writeln(output,'fraction of scouts:',f_scouts);
  writeln(output,'flow:',flow);
  writeln(output,'n:',n);
  writeln(output,'k:',k);
  writeln(output,'__________');
  writeln(output,'results:');                         //Ergebnisse
  writeln(output,'');
  writeln(output,'intake',intake:7:0);
  writeln(output,'sum of moves',move_sum:7:0);
  writeln(output,'');
  for patch:=1 to n_patches do
    begin
    writeln(output,'patch:',patch);
    writeln(output,'distance:',
      Distance(Patches[patch].x,Patches[patch].y,Nest.x,Nest.y):3:1);
    if n_patches = 2 then writeln('time delay:',patch_delay);
    writeln(output,'ants:',Patches[patch].ants);
    writeln(output,'ants:',Patches[patch].trail[1]:5:0);
    writeln(output,'');
    end;
  closefile(output);                                  //Textfile schließen
  end;

//______________________________________________________________________________

procedure TForm1.p_Max_ScoutEditChange(Sender: TObject);
  var max,inc : double;
  begin
  ReadCapDouble(Form1.p_Max_ScoutEdit.text,max);
  if max > 1 then
    begin
    Form1.p_Max_ScoutEdit.text := '1';
    ReadCapDouble(Form1.p_Max_ScoutEdit.text,max);
    end;
  ReadCapDouble(Form1.p_Inc_ScoutEdit.text,inc);
  PGraph(max,inc);
  end;

procedure TForm1.p_Inc_ScoutEditChange(Sender: TObject);
  var max,inc : double;
  begin
  ReadCapDouble(Form1.p_Max_ScoutEdit.text,max);
  ReadCapDouble(Form1.p_Inc_ScoutEdit.text,inc);
  PGraph(max,inc);
  end;

//______________________________________________________________________________


end.
