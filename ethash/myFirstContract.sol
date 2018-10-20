pragma solidity ^0.4.16;

 contract myFirst {
     string name;
     uint age;

     event First(
         string name,
         uint age
     );

     function getVal() view public returns (string, uint) {
         return(name, age);
     }

     function setVal(string _name, uint _age) public {
         name = _name;
         age = _age;
         emit First(name, age);
     }
 }
