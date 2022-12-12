import {Address} from '@graphprotocol/graph-ts';

export const ADDRESS_ZERO = '0x0000000000000000000000000000000000000000';
export const ADDRESS_ONE = '0x0000000000000000000000000000000000000001';
export const ADDRESS_TWO = '0x0000000000000000000000000000000000000002';
export const ADDRESS_THREE = '0x0000000000000000000000000000000000000003';
export const ADDRESS_FOUR = '0x0000000000000000000000000000000000000004';
export const ADDRESS_FIVE = '0x0000000000000000000000000000000000000005';

export const DAO_TOKEN_ADDRESS = '0x6B175474E89094C44Da98b954EedeAC495271d0F';

export const DAO_ADDRESS = '0x00000000000000000000000000000000000000DA';
export const VOTING_ADDRESS = '0x00000000000000000000000000000000000000Ad';
export const PROPOSAL_ID = '0';
export const PROPOSAL_ENTITY_ID =
  Address.fromString(VOTING_ADDRESS).toHexString() + '_0x' + PROPOSAL_ID;

export const STRING_DATA = 'Some String Data ...';

export const ONE_ETH = '1000000000000000000';
export const HALF_ETH = '500000000000000000';

export const ONE_HOUR = '3600';

export const EARLY_EXECUTION = true;
export const VOTE_REPLACEMENT = false;
export const SUPPORT_THRESHOLD = '500000000000000000';
export const MIN_PARTICIPATION = '500000000000000000';
export const MIN_DURATION = ONE_HOUR;

export const MIN_PROPOSER_VOTING_POWER = '0';
export const START_DATE = '1644851000';
export const END_DATE = '1644852000';
export const SNAPSHOT_BLOCK = '100';

export const TOTAL_VOTING_POWER = '3';
export const CREATED_AT = '1644850000';
