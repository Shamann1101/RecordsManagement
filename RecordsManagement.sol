pragma solidity ^0.4.18;

library Structures {

    struct Record {

        string title;

        string desc;

        uint256 creation_date;

        uint256 life_time;

    }
}

/*
"1", "2", "3", "4"
"2", "2", "1511827200", "3600"
*/
contract RecordsManagement {

    mapping (bytes32 => Structures.Record) records;

    bytes32[] indexes;

    uint index_i;

    event Add (string title, string desc, uint256 life_time);

    modifier index_isset(string index) {
        for (uint i = 0; i < indexes.length; i++) {
            if (indexes[i] == keccak256(index)) {
                index_i = i;
                _;
            }
        }
    }

    modifier life_time_cycle (string index) {
        uint die_day = records[keccak256(index)].creation_date + records[keccak256(index)].life_time;
        uint today = now;
        if (die_day < today) {
           del(index);
        } else {
            _;
        }
    }

    function RecordsManagement() public {

        add("1", "2", 3);
        add("2", "2", 3600);

    }

    function add(string title, string desc, uint256 life_time) public returns(bool){
        records[keccak256(title)] = Structures.Record(title, desc, now, life_time);
        indexes.push(keccak256(title));
        Add (title, desc, life_time);
        return true;
    }

    function edit(string title, string desc, uint256 life_time) public index_isset(title) life_time_cycle(title) returns(bool){
        records[keccak256(title)] = Structures.Record(title, desc, records[keccak256(title)].creation_date, life_time);
        return true;
    }

    function search(string index) public life_time_cycle(index) returns(Structures.Record) {
        for (uint i = 0; i < indexes.length; i++) {
            if (indexes[i] == keccak256(index)) {
                return records[keccak256(index)];
            }
        }
        return;
    }

    function del(string index) public index_isset(index) returns(bool){
        delete records[keccak256(index)];
        remove_index(index_i);
        return true;
    }

    function remove_index(uint index) internal returns(bytes32[]) {
        if (index >= indexes.length) return;

        indexes[index] = indexes[indexes.length-1];
        delete indexes[indexes.length-1];
        indexes.length--;

        return indexes;
    }

    function indexesLength() public constant returns(uint){
        return indexes.length;
    }
    
    function get_title(string index) public index_isset(index) returns(string) {
        return records[keccak256(index)].title;
    }
    
    function iterate() public{
        for (uint i = 0; i < indexes.length; i++) {
            search(records[indexes[i]].title);
        }
    }

    function indexes_view() public{
        // Need action
    }
}