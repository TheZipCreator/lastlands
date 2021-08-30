class DiplomaticRelation { //Diplomatic relation between two chiefdoms
  int type;
  /*
  0=Alliance
  1=War
  2=Tributary (chiefdomA is the overlord)
  */
  String chiefdomA; //Tags to both chiefdoms in the relation
  String chiefdomB;
  
  DiplomaticRelation(int type, String chiefdomA, String chiefdomB) {
    this.type = type;
    this.chiefdomA = chiefdomA;
    this.chiefdomB = chiefdomB;
  }
  
  boolean containsMembers(String chiefdomA_, String chiefdomB_) { //Test if this DiplomaticRelation contains 2 chiefdoms
    return (chiefdomA_.equals(chiefdomA) && chiefdomB_.equals(chiefdomB)) || (chiefdomB_.equals(chiefdomA) && chiefdomA_.equals(chiefdomB));
  }
}
