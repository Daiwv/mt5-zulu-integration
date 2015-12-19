//+------------------------------------------------------------------+
//|                                                            JAson |
//|                       programming & development - Alexey Sergeev |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2006-2015  Alexey Sergeev"
#property link      "profy.mql@gmail.com"
#property version "1.02"
#property strict
//+------------------------------------------------------------------+
//| enum enJAType                                                    |
//+------------------------------------------------------------------+
enum enJAType { jtUNDEF,jtNULL,jtBOOL,jtINT,jtDBL,jtSTR,jtARRAY,jtOBJ };
//+------------------------------------------------------------------+
//| class CJAVal                                                     |
//+------------------------------------------------------------------+
class CJAVal
  {
public:
   virtual void Clear() { m_parent=NULL; m_key=""; m_type=jtUNDEF; m_bv=false; m_iv=0; m_dv=0; m_sv=""; ArrayResize(m_e,0); }
   virtual bool Copy(const CJAVal &a) { m_parent=GetPointer(a.m_parent); m_key=a.m_key; m_type=a.m_type; m_bv=a.m_bv; m_iv=a.m_iv; m_dv=a.m_dv; m_sv=a.m_sv; CopyArr(a); return true; }
   virtual void CopyData(const CJAVal &a) { m_type=a.m_type; m_bv=a.m_bv; m_iv=a.m_iv; m_dv=a.m_dv; m_sv=a.m_sv; CopyArr(a); }
   virtual void CopyArr(const CJAVal &a) { ArrayResize(m_e,ArraySize(a.m_e)); for(int i=0; i<ArraySize(m_e); i++) m_e[i]=a.m_e[i]; }

public:
   CJAVal            m_e[];
   string            m_key;
   string            m_lkey;
   CJAVal           *m_parent;
   enJAType          m_type;
   bool              m_bv;
   long              m_iv;
   double            m_dv;
   string            m_sv;

public:
                     CJAVal() { Clear(); }
                     CJAVal(CJAVal *aparent,enJAType atype) { Clear(); m_type=atype; m_parent=aparent; }
                     CJAVal(enJAType t,string a) { Clear(); FromStr(t,a); }
                     CJAVal(const int a) { Clear(); m_type=jtINT; m_iv=a; m_dv=(double)m_iv; m_sv=IntegerToString(m_iv); m_bv=m_iv!=0; }
                     CJAVal(const long a) { Clear(); m_type=jtINT; m_iv=a; m_dv=(double)m_iv; m_sv=IntegerToString(m_iv); m_bv=m_iv!=0; }
                     CJAVal(const double a) { Clear(); m_type=jtDBL; m_dv=a; m_iv=(long)m_dv; m_sv=DoubleToString(m_dv); m_bv=m_iv!=0; }
                     CJAVal(const bool a) { Clear(); m_type=jtBOOL; m_bv=a; m_iv=m_bv; m_dv=m_bv; m_sv=IntegerToString(m_iv); }
                     CJAVal(const CJAVal &a) { Copy(a); }
                    ~CJAVal() { Clear(); }

public:
   virtual bool IsNumeric() { return m_type==jtDBL || m_type==jtINT; }
   virtual CJAVal *FindKey(string akey) { for(int i=0; i<ArraySize(m_e); i++) if(m_e[i].m_key==akey) return GetPointer(m_e[i]); return NULL; }
   virtual CJAVal   *HasKey(string akey,enJAType atype=jtUNDEF);
   CJAVal           *operator[](string akey);
   void operator=(const CJAVal &a) { Copy(a); }
   void operator=(const int a) { m_type=jtINT; m_iv=a; m_dv=(double)m_iv; m_bv=m_iv!=0; }
   void operator=(const long a) { m_type=jtINT; m_iv=a; m_dv=(double)m_iv; m_bv=m_iv!=0; }
   void operator=(const double a) { m_type=jtDBL; m_dv=a; m_iv=(long)m_dv; m_bv=m_iv!=0; }
   void operator=(const bool a) { m_type=jtBOOL; m_bv=a; m_iv=(long)m_bv; m_dv=(double)m_bv; }
   void operator=(string a) { m_type=a?jtSTR:jtNULL; m_sv=a; m_iv=StringToInteger(m_sv); m_dv=StringToDouble(m_sv); m_bv=a!=NULL; }
   //---
   bool operator==(const int a) { return m_iv==a; }
   bool operator==(const long a) { return m_iv==a; }
   bool operator==(const double a) { return m_dv==a; }
   bool operator==(const bool a) { return m_bv==a; }
   bool operator==(string a) { return m_sv==a; }
   //---
   bool operator!=(const int a) { return m_iv!=a; }
   bool operator!=(const long a) { return m_iv!=a; }
   bool operator!=(const double a) { return m_dv!=a; }
   bool operator!=(const bool a) { return m_bv!=a; }
   bool operator!=(string a) { return m_sv!=a; }
   //---
   long ToInt() const { return m_iv; }
   double ToDbl() const { return m_dv; }
   bool ToBool() const { return m_bv; }
   string ToStr() { return m_sv; }
   //---
   virtual void FromStr(enJAType t,string a)
     {
      m_type=t;
      switch(m_type)
        {
         case jtBOOL: m_bv=(StringToInteger(a)!=0); m_iv=(long)m_bv; m_dv=(double)m_bv; m_sv=a; break;
         case jtINT: m_iv=StringToInteger(a); m_dv=(double)m_iv; m_sv=a; m_bv=m_iv!=0; break;
         case jtDBL: m_dv=StringToDouble(a); m_iv=(long)m_dv; m_sv=a; m_bv=m_iv!=0; break;
         case jtSTR: m_sv=a; m_type=a?jtSTR:jtNULL; m_iv=StringToInteger(m_sv); m_dv=StringToDouble(m_sv); m_bv=a!=NULL; break;
        }
     }
   virtual string GetStr(char &js[],int i,int slen) { string ss=""; for(int s=0; s<slen; s++) StringSetCharacter(ss,StringLen(ss),js[i+s]); return ss; }
   //---
   virtual void Set(const CJAVal &a) { if(m_type==jtUNDEF) m_type=jtOBJ; CopyData(a); }
   virtual CJAVal *Add(const CJAVal &item) { if(m_type==jtUNDEF) m_type=jtARRAY; /*ASSERT(m_type==jtOBJ || m_type==jtARRAY);*/ return AddBase(item); } // ����������
   virtual CJAVal *AddBase(const CJAVal &item) { int c=ArraySize(m_e); ArrayResize(m_e,c+1); m_e[c]=item; return GetPointer(m_e[c]); } // ����������
   virtual CJAVal *New() { if(m_type==jtUNDEF) m_type=jtARRAY; /*ASSERT(m_type==jtOBJ || m_type==jtARRAY);*/ return NewBase(); } // ����������
   virtual CJAVal *NewBase() { int c=ArraySize(m_e); ArrayResize(m_e,c+1); return GetPointer(m_e[c]); } // ����������

public:
   virtual void      Serialize(string &js,bool bf=false);
   virtual string Serialize() { string js; Serialize(js); return js; }
   virtual bool      Deserialize(char &js[],int slen,int &i);
   virtual bool      ExtrStr(char &js[],int slen,int &i);
   virtual bool Deserialize(string js) { int i=0; Clear(); char arr[]; int slen=StringToCharArray(js,arr); return Deserialize(arr,slen,i); }
   virtual bool Deserialize(char &js[]) { int i=0; Clear(); return Deserialize(js,ArraySize(js),i); }
  };
//+------------------------------------------------------------------+
//| HasKey                                                           |
//+------------------------------------------------------------------+
CJAVal *CJAVal::HasKey(string akey,enJAType atype/*=jtUNDEF*/) { for(int i=0; i<ArraySize(m_e); i++) if(m_e[i].m_key==akey) { if(atype==jtUNDEF || atype==m_e[i].m_type) return GetPointer(m_e[i]); break; } return NULL; }
//+------------------------------------------------------------------+
//| operator[]                                                       |
//+------------------------------------------------------------------+
CJAVal *CJAVal::operator[](string akey) { if(m_type==jtUNDEF) m_type=jtOBJ; CJAVal *v=FindKey(akey); if(v) return v; CJAVal b(GetPointer(this),jtUNDEF); b.m_key=akey; v=Add(b); return v; }
//+------------------------------------------------------------------+
//| Serialize                                                        |
//+------------------------------------------------------------------+
void CJAVal::Serialize(string &js,bool bkey/*=false*/)
  {
   if(m_type==jtUNDEF) return;
   if(bkey) js+=StringFormat("\"%s\":",m_key);
   int _n=ArraySize(m_e);
   switch(m_type)
     {
      case jtNULL: js+="null"; break;
      case jtBOOL: js+=(m_bv?"true":"false"); break;
      case jtINT: js+=IntegerToString(m_iv); break;
      case jtDBL: js+=DoubleToString(m_dv); break;
      case jtSTR: if(m_sv!="") js+=StringFormat("\"%s\"",m_sv); else js+="null"; break;
      case jtARRAY: StringSetCharacter(js,StringLen(js),'['); for(int i=0; i<_n; i++) { m_e[i].Serialize(js, false); if(_n>1 && i<_n-1) StringSetCharacter(js, StringLen(js), ','); } StringSetCharacter(js, StringLen(js), ']'); break;
      case jtOBJ: StringSetCharacter(js, StringLen(js), '{'); for(int i=0; i<_n; i++) { m_e[i].Serialize(js, true); if(_n>1 && i<_n-1) StringSetCharacter(js, StringLen(js), ','); } StringSetCharacter(js, StringLen(js), '}'); break;
     }
  }
//+------------------------------------------------------------------+
//| Deserialize                                                      |
//+------------------------------------------------------------------+
bool CJAVal::Deserialize(char &js[],int slen,int &i)
  {
   string num="0123456789+-.eE";
   int i0=i;
   for(; i<slen; i++)
     {
      char c=js[i]; if(c==0) break;
      switch(c)
        {
         case '\t': case '\r': case '\n': case ' ': // ���������� �� ����� �������
            i0=i+1; break;
            //---
         case '[': // ������ �������. ������� ������� � �������� �� js
           {
            i0=i+1;
            if(m_type!=jtUNDEF) { return false; } // ���� �������� ��� ����� ���, �� ��� ������
            m_type=jtARRAY; // ������ ��� ��������
            i++; CJAVal val(GetPointer(this),jtUNDEF);
            while(val.Deserialize(js,slen,i))
              {
               if(val.m_type!=jtUNDEF) Add(val);
               val.Clear(); val.m_parent=GetPointer(this);
               if(js[i]==']') break;
               i++; if(i>=slen) { return false; }
              }
            return js[i]==']' || js[i]==0;
           }
         break;
         case ']': return m_parent.m_type==jtARRAY; // ����� �������, ������� �������� ������ ���� ��������
         //---
         case ':':
           {
            if(m_lkey=="") { return false; }
            CJAVal val(GetPointer(this),jtUNDEF);
            CJAVal *oc=Add(val); // ��� ������� ���� �� ���������
            oc.m_key=m_lkey; m_lkey=""; // ������ ��� �����
            i++; if(!oc.Deserialize(js,slen,i)) { return false; }
            break;
           }
         case ',': // ����������� �������� // ��� �������� ��� ������ ���� ���������
            i0=i+1;
            if(!m_parent && m_type!=jtOBJ) { return false; }
            else if(m_parent)
              {
               if(m_parent.m_type!=jtARRAY && m_parent.m_type!=jtOBJ) { return false; }
               if(m_parent.m_type==jtARRAY && m_type==jtUNDEF) return true;
              }
            break;
            //--- ��������� ����� ���� ������ � ������� / ���� ��������������
         case '{': // ������ �������. ������� ������ � �������� ��� �� js
            i0=i+1;
            if(m_type!=jtUNDEF) { return false; }// ������ ����
            m_type=jtOBJ; // ������ ��� ��������
            i++; if(!Deserialize(js,slen,i)) { return false; } // ���������� ���
            return js[i]=='}' || js[i]==0;
            break;
         case '}': return m_type==jtOBJ; // ����� �������, ������� �������� ������ ���� ��������
         //---
         case 't': case 'T': // ������ true
         case 'f': case 'F': // ������ false
         if(m_type!=jtUNDEF) { return false; } // ������ ����
         m_type=jtBOOL; // ������ ��� ��������
         if(i+3<slen) { if(StringCompare(GetStr(js, i, 4), "true", false)==0) { m_bv=true; i+=3; return true; } }
         if(i+4<slen) { if(StringCompare(GetStr(js, i, 5), "false", false)==0) { m_bv=false; i+=4; return true; } }
         return false; // �� ��� ��� ��� ����� ������
         break;
         case 'n': case 'N': // ������ null
         if(m_type!=jtUNDEF) { return false; } // ������ ����
         m_type=jtNULL; // ������ ��� ��������
         if(i+3<slen) if(StringCompare(GetStr(js,i,4),"null",false)==0) { i+=3; return true; }
         return false; // �� NULL ��� ����� ������
         break;
         //---
         case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '-': case '+': case '.': // ������ �����
           {
            if(m_type!=jtUNDEF) { return false; } // ������ ����
            bool dbl=false;// ������ ��� ��������
            int is=i; while(js[i]!=0 && i<slen) { i++; if(StringFind(num,GetStr(js,i,1))<0) break; if(!dbl) dbl=(js[i]=='.' || js[i]=='e' || js[i]=='E'); }
            m_sv=GetStr(js,is,i-is);
            if(dbl) { m_type=jtDBL; m_dv=StringToDouble(m_sv); m_iv=(long)m_dv; }
            else { m_type=jtINT; m_iv=StringToInteger(m_sv); m_dv=(double)m_iv; } // ������� ��� ��������
            i--; return true; // ������������ �� 1 ������ ����� � �����
            break;
           }
         case '\"': // ������ ��� ����� ������
            if(m_type==jtOBJ) // ���� ��� ��� ����������� � ���� �� �����
              {
               i++; int is=i; if(!ExtrStr(js,slen,i)) { return false; } // ��� ����, ���� �� ����� ������
               m_lkey=GetStr(js,is,i-is);
              }
            else
              {
               if(m_type!=jtUNDEF) { return false; } // ������ ����
               m_type=jtSTR; // ������ ��� ��������
               i++; int is=i;
               if(!ExtrStr(js,slen,i)) { return false; }
               FromStr(jtSTR,GetStr(js,is,i-is));
               return true;
              }
            break;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//| ExtrStr                                                          |
//+------------------------------------------------------------------+
bool CJAVal::ExtrStr(char &js[],int slen,int &i)
  {
   for(; js[i]!=0 && i<slen; i++)
     {
      char c=js[i];
      if(c=='\"') break; // ����� ������
      if(c=='\\' && i+1<slen)
        {
         i++; c=js[i];
         switch(c)
           {
            case '\"': case '/': case '\\': case 'b': case 'f': case 'r': case 'n': case 't': break; // ��� �����������
            case 'u': // \uXXXX
               i++;
               for(int j=0; j<4 && i<slen && js[i]!=0; i++,j++)
                 {
                  if(!((js[i]>='0' && js[i]<='9') || (js[i]>='A' && js[i]<='F') || (js[i]>='a' && js[i]<='f'))) { return false; } // �� hex
                 }
               i--;
               break;
            default: break; /*{ return false; } // ������������� ������ � �������������� */
           }
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
