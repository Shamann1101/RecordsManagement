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
    event Edit(string title, string desc, uint256 life_time);
    event Del(string index);

    /**
     * @dev Works if there is an index
     */
    modifier index_isset(string _title) {
        for (uint i = 0; i < indexes.length; i++) {
            if (indexes[i] == keccak256(_title)) {
                index_i = i;
                _;
            }
        }
    }

    /**
     * @dev Works if life_time has not expired
     */
    modifier life_time_cycle(string _title) {
        uint die_day = records[keccak256(_title)].creation_date + records[keccak256(_title)].life_time;
        if (die_day < now) {
            del(_title);
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
     * @param _title Title of record.
     * @param _desc Description of record.
     * @param _life_time Life time of record.
     * @return bool
     */
    function add(string _title, string _desc, uint256 _life_time) public returns(bool) {
        bool state;
        string memory title;
        string memory desc;
        uint256 creation_date;
        uint256 life_time;
        (state, title, desc, creation_date, life_time) = search(_title);
        if (state == true)
            return;

        records[keccak256(_title)] = Structures.Record(_title, _desc, now, _life_time);
        indexes.push(keccak256(_title));
        Add(_title, _desc, _life_time);
        return true;
    }

    /**
     * @dev Editing a record, returns true if ok
     * @param _title Title of record.
     * @param _desc Description of record.
     * @param _life_time Life time of record.
     * @return bool
     */
    function edit(string _title, string _desc, uint256 _life_time) public index_isset(_title) life_time_cycle(_title) returns(bool) {
        records[keccak256(_title)] = Structures.Record(_title, _desc, records[keccak256(_title)].creation_date, _life_time);
        Edit(_title, _desc, _life_time);
        return true;
    }

    /**
     * @dev Searching a record
     * @param _title Title of record.
     * @return bool state, string title, string description, uint256 creation_date, uint256 life_time
     */
    function search(string _title) public life_time_cycle(_title) returns(
        bool state,
        string title,
        string description,
        uint256 creation_date,
        uint256 life_time
        ) {
        for (uint i = 0; i < indexes.length; i++) {
            if (indexes[i] == keccak256(_title)) {
                return (
                    true,
                    records[keccak256(_title)].title,
                    records[keccak256(_title)].desc,
                    records[keccak256(_title)].creation_date,
                    records[keccak256(_title)].life_time
                );
            }
        }
        return;
    }

    /**
     * @dev Delete a record, returns true if ok
     * @param _title Title of record.
     * @return bool
     */
    function del(string _title) public index_isset(_title) returns(bool) {
        delete records[keccak256(_title)];
        remove_index(index_i);
        Del(_title);
        return true;
    }

    /**
     * @dev Remove index from indexes array
     * @param _index Title of record.
     * @return bytes32[]
     */
    function remove_index(uint _index) internal returns(bytes32[]) {
        if (_index >= indexes.length) return;

        indexes[_index] = indexes[indexes.length - 1];
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
     * @dev Returns a title of a record by encoded index
     * @param _index Title of record.
     * @return string
     */
    function get_title(bytes32 _index) public constant returns(string) {
        return records[_index].title;
    }

    /**
     * @dev Returns array of encoded indexes
     * @return bytes32[]
     */
    function indexesView() public returns(bytes32[]) {
        for (uint i = 0; i < indexes.length; i++) {
            search(records[indexes[i]].title);
        }
        return indexes;
    }
}
