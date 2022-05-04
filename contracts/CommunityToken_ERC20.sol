// SPDX-License-Identifier: MIT
pragma solidity 0.8;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "https://github.com/RonTuretzky/CommunityToken/blob/4ad3df836aac20907443b42323342e0fb7e470d2/CommunityToken.sol";
import "./CommunityToken.sol";

contract CommunityToken_ERC20 is ERC20, CommunityToken {
    address _WITH_ADMIN;
    //Mapping of a user, to a mapping of event ids
    //to a mapping of adresses and boolean values
    // Host => Event ID => Address => Attended/Not Attended
    struct Event {
        address _host;
        bool _token_payable;
        mapping(address => bool) Attendees;
    }
    mapping(uint256 => Event) private _event_ledger;
    mapping(address => bool) private users;
    mapping(address => uint8) private counter;

    constructor(address WITH_ADMIN_) ERC20("Tel Hai", "WITH_TH") {
        _WITH_ADMIN = WITH_ADMIN_;
        _mint(_WITH_ADMIN, 3);
    }

    //----------------------- Event Ledger Functions ------------------------------------//
    function add_event(
        uint256 event_id_,
        address host_,
        bool token_payable_
    ) public virtual override returns (bool) {
        require(msg.sender == _WITH_ADMIN, "Only Admins can add events");
        _event_ledger[event_id_].Attendees[host_] = true; // Prevents host getting tokens from their own events
        _event_ledger[event_id_]._token_payable = token_payable_;
        _event_ledger[event_id_]._host = host_;
        return true;
    }

    function verify_attendence(uint256 event_id_, address attendee)
        public
        virtual
        override
        returns (bool)
    {
        require(
            _event_ledger[event_id_]._host == msg.sender &&
                _event_ledger[event_id_].Attendees[attendee] != true,
            "Event doesn't exist, attendence was already verified, or you are not the host"
        );
        _event_ledger[event_id_].Attendees[attendee] = true;
        increment_count(attendee);
        return true;
    }

    //----------------------- Counter Functions ------------------------------------//

    function increment_count(address attendee) internal returns (bool) {
        counter[attendee]++;
        if (counter[attendee] == 3) {
            counter[attendee] = 0;
            _mint(attendee, 1);
        }
        return true;
    }

    //----------------------- User Functions ------------------------------------//
    function add_user(address new_user_)
        public
        virtual
        override
        returns (bool)
    {
        require(msg.sender == _WITH_ADMIN, "Unauthorized Action");
        users[new_user_] = true;
        return true;
    }

    function event_payment(uint256 event_id)
        public
        virtual
        override
        returns (bool)
    {
        // Need to make sure this call can't be done through the coing api if the event isn't open for signup
        // If a raw user is using this contract it's his obligation to check whether the event is still open
        // For registration
        require(
            _event_ledger[event_id]._token_payable == true,
            "You cannot pay for this event with tokens"
        );
        transfer(_event_ledger[event_id]._host, 1);
        return true;
    }

    //----------------------- User Functions ------------------------------------//
}
