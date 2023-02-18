import styled from 'styled-components';

export const SponsorBannerStyle = styled.div`
  max-height: 2.2em;
  min-height: 2.2em;
  margin-bottom: 16px;
  width: 100%;
  border-radius: 10px;
  background-color: #5c94f5;
  //background-color: #2e294e;
  //background-color: #847fec;
  height: 50px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  gap: 4px;

  button {
    font-size: 14px;
    line-height: 16px;
    font-weight: 500;
    cursor: pointer;
    -webkit-appearance: unset;
    background-color: transparent;
    border: none;
    color: #fafafa;
  }
`;
