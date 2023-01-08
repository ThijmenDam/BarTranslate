import styled from 'styled-components';

export const SettingsGroupTitleStyle = styled.span`
  font-size: 12px;
  text-transform: uppercase;
  color: #717077;
  font-weight: 200;
  margin-bottom: 6px;
  padding-left: 6px;
`;

export const SettingsGroupStyle = styled.div`
  width: 100%;
  background-color: #fff;
  padding: 12px 16px;
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 20px;

  hr {
    margin-top: 10px;
    border: none;
    height: 1px;
    width: calc(100% + 16px);
    background-color: #ededed;
  }
`;

export const SettingsStyle = styled.div`
  height: 100%;
  width: 100%;
  display: flex;
  justify-content: space-between;
  flex-direction: column;
`;

export const ContainerStyle = styled.div`
  height: auto;
  width: 100%;
  padding: 18px 16px;
  margin: auto;
  flex: 1;
  display: flex;
  flex-direction: column;
  color: #303030;
`;

export const SponsorStyle = styled.div`
  background-color: #5c94f5;
  width: 100%;
  height: 50px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  gap: 4px;

  button {
    font-size: 14px;
    font-weight: 500;

    cursor: pointer;
    -webkit-appearance: unset;
    background-color: transparent;
    border: none;
    color: #fafafa;
  }
`;

export const EmojiStyle = styled.div`
  font-size: 16px;
`;
