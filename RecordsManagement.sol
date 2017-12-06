pragma solidity ^0.4.19;

library Structures {

    struct Record {

        string title;

        string desc;

        uint256 creation_date;

        uint256 life_time;

    }
}

contract RecordsManagement {

    mapping(bytes32 => Structures.Record) records;

    bytes32[] indexes;

    uint index_i;

    event Add(string title, string desc, uint256 life_time);

    /**
     * @dev Works if there is an index
     */
    modifier index_isset(string index) {
        for (uint i = 0; i < indexes.length; i++) {
            if (indexes[i] == keccak256(index)) {
                index_i = i;
                _;
            }
        }
    }

    /**
     * @dev Works if life_time has not expired
     */
    modifier life_time_cycle(string index) {
        uint die_day = records[keccak256(index)].creation_date + records[keccak256(index)].life_time;
        if (die_day < now) {
            del(index);
        } else {
            _;
        }
    }

    /**
     * @dev Constructor
     */
    function RecordsManagement() public {

        add("1", "2", 30);
        add("2", "2", 3600);

    }

    /**
     * @dev Adding a record, returns true if ok
     * @param title Title of record.
     * @param desc Description of record.
     * @param life_time Life time of record.
     * @return bool
     */
    function add(string title, string desc, uint256 life_time) public returns(bool) {
        // TODO: Add an index existence check
        records[keccak256(title)] = Structures.Record(title, desc, now, life_time);
        indexes.push(keccak256(title));
        Add(title, desc, life_time);
        return true;
    }

    /**
     * @dev Editing a record, returns true if ok
     * @param title Title of record.
     * @param desc Description of record.
     * @param life_time Life time of record.
     * @return bool
     */
    function edit(string title, string desc, uint256 life_time) public index_isset(title) life_time_cycle(title) returns(bool) {
        records[keccak256(title)] = Structures.Record(title, desc, records[keccak256(title)].creation_date, life_time);
        return true;
    }

    /**
     * @dev Searching a record
     * @param index Title of record.
     * @return Structures.Record
     */
    function search(string index) public life_time_cycle(index) returns(Structures.Record) {
        for (uint i = 0; i < indexes.length; i++) {
            if (indexes[i] == keccak256(index)) {
                return (records[keccak256(index)]);
            }
        }
        return;
    }

    /**
     * @dev Delete a record, returns true if ok
     * @param index Title of record.
     * @return bool
     */
    function del(string index) public index_isset(index) returns(bool) {
        delete records[keccak256(index)];
        remove_index(index_i);
        return true;
    }

    /**
     * @dev Remove index from indexes array
     * @param index Title of record.
     * @return bytes32[]
     */
    function remove_index(uint index) internal returns(bytes32[]) {
        if (index >= indexes.length) return;

        indexes[index] = indexes[indexes.length - 1];
        delete indexes[indexes.length - 1];
        indexes.length--;

        return indexes;
    }

    /**
     * @dev Returns length of indexes array
     * @return uint
     */
    function indexesLength() public constant returns(uint) {
        return indexes.length;
    }

    /**
     * @dev Returns a title of a record by index
     * @param index Title of record.
     * @return string
     */
    function get_title(string index) public constant index_isset(index) returns(string) {
        return records[keccak256(index)].title;
    }

    /**
     * @dev Returns array of encoded indexes
     * @return bytes32[]
     */
    function indexes_view() public returns(bytes32[]) {
        for (uint i = 0; i < indexes.length; i++) {
            search(records[indexes[i]].title);
        }
        return indexes;
    }
}