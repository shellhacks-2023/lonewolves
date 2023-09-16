IMPORT $;
WeatherDS  := $.File_Composite.WeatherScoreDS;
CrimeDS    := $.File_Composite.CrimeScoreDS;
EdDS       := $.File_Composite.EduScoreDS;
HealthDS   := $.File_Composite.MortScoreDS;
CombLayout := $.File_Composite.Layout;
iParadiseInterface:=$.iParadise;




MergeWeather := PROJECT(WeatherDS,TRANSFORM(CombLayout,SELF.StateName := $.DCT.MapST2Name(LEFT.State),SELF := LEFT,SELF := []));
//OUTPUT(MergeWeather,NAMED('AddStateToWeather'));

// ViolentCompRat;
// PropCompRat;
// ViolentScore;
// PropCrimeScore;
MergeCrime := JOIN(MergeWeather,CrimeDS,
                   LEFT.State = Right.State,
                   TRANSFORM(CombLayout,
                             SELF.ViolentCompRat := RIGHT.ViolentCompRat,
                             SELF.PropCompRat    := RIGHT.PropCompRat,
                             SELF.ViolentScore   := RIGHT.ViolentScore,
                             SELF.PropCrimeScore := RIGHT.PropCrimeScore,
                             SELF := LEFT),LOOKUP);

//OUTPUT(iParadiseInterface.Public_School_Count+' Hello');
//OUTPUT(MergeCrime,NAMED('CrimeandWeather'));

// pubcnt;
// prvcnt;
// avestratio;
// StudentTeacherScore;
// PrvSchoolScore;
// PublicSchoolScore;
MergeEducation := JOIN(MergeCrime,EdDS,
                       LEFT.State = Right.State,
                       TRANSFORM(CombLayout,
                                 SELF.pubcnt              := RIGHT.pubcnt,
                                 SELF.prvcnt              := RIGHT.prvcnt,
                                 SELF.avestratio          := RIGHT.avestratio,
                                 SELF.StudentTeacherScore := RIGHT.StudentTeacherScore,
                                 SELF.PrvSchoolScore      := RIGHT.PrvSchoolScore,
                                 SELF.PublicSchoolScore   := RIGHT.PublicSchoolScore,
                                 SELF := LEFT),LOOKUP);
//OUTPUT(MergeEducation,NAMED('CrimeWeatherEducation'));

// sumcum;
// maxcum;
// mincum;
// MortalityScore;
MergeAll := JOIN(MergeEducation,HealthDS,
                    LEFT.State = Right.State,
                    TRANSFORM(CombLayout,
                    SELF.sumcum := RIGHT.sumcum,
                    SELF.maxcum := RIGHT.maxcum,
                    SELF.mincum := RIGHT.mincum,
                    SELF.MortalityScore := RIGHT.MortalityScore,
                    SELF := LEFT),LOOKUP);

// Define a map structure
/*MyMap := DATASET([
  {1, 'Alice'},
  {2, 'Bob'},
  {3, 'Charlie'}
], {INTEGER1 Id, STRING Name});
*/
//MyMap:=DATASET([{1,DATASET([{101,'ALice'},{102,'Bob'}],{DECIMAL5_2 rollNumber,STRING name})}],{DECIMAL5_2 id,DATASET dd});
/*InnerMapRec := RECORD
    STRING State;
    INTEGER score;
END;

// Define the structure of the outer map with keys as INT and values as InnerMapRec
OuterMapRec := RECORD
    STRING particularScore;
    DATASET(InnerMapRec) Value;
END;

// Create an instance of the inner map
InnerMap := DATASET([
    {'TX', 25},
    {'FL', 30},
    {'CA', 35}
], InnerMapRec);

// Create an instance of the outer map and populate it
OuterMap := DATASET([
    {'eventScore', InnerMap},
    {'violentScore', DATASET([{'NY', 40}], InnerMapRec)}
], OuterMapRec);
OUTPUT(OuterMap);*/
//OUTPUT(iParadiseInterface.Student_Teacher_Ratio);
//OUTPUT(MyMap);

//CombLayout CompTotal(CombLayout Le) := TRANSFORM
 /*SELF.ParadiseScore := Le.StudentTeacherScore + Le.PrvSchoolScore + Le.PublicSchoolScore + Le.ViolentScore + Le.PropCrimeScore +
                       Le.MortalityScore + Le.EvtScore + Le.InjScore + Le.FatScore;*/
    /*SELF.ParadiseScore:=0;
    IF iParadiseInterface.Student_Teacher_Ratio THEN
    ParadiseScore:=SELF.ParadiseScore+Le.StudentTeacherScore;
 SELF := Le;
END;*/
CombLayout CompTotal(CombLayout Le) := TRANSFORM
    SELF.ParadiseScore := 0;
   // SELF.printHello := '';
    IF iParadiseInterface.Student_Teacher_Ratio THEN
        //OUTPUT('Hello');
        //PrintHello := 'Hello';
        ParadiseScore :=SELF.ParadiseScore+Le.StudentTeacherScore;
    ELSE 
        ParadiseScore:=0;
    END;
    //OUTPUT(LEFT, NAMED('TransformedDataset'));
SELF := Le;

END;


ParadiseSummary := PROJECT(MergeAll,CompTotal(LEFT));

OUTPUT(ParadiseSummary,,'~FYP::Main::Hacks::ParadiseScores',NAMED('Final_Output'),OVERWRITE);
 