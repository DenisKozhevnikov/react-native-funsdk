import { StyleSheet } from 'react-native';

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 130,
    paddingHorizontal: 8,
    backgroundColor: 'pink',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
    padding: 20,
  },
  monitor: {
    width: '100%',
    aspectRatio: 16 / 9,
    backgroundColor: 'yellow',
  },
  button: {
    margin: 5,
    padding: 8,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'green',
    borderRadius: 5,
    minHeight: 40,
  },
  buttonDisabled: {
    backgroundColor: 'gray',
    opacity: 0.6,
  },
  buttonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '500',
  },
  view: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    backgroundColor: '#EFEFEF',
  },
  scrollView: {
    marginTop: 30,
    padding: 10,
    backgroundColor: '#EFEFEF',
  },
  // Новые стили для DeviceSearch
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 15,
    color: '#333',
  },
  inputContainer: {
    marginBottom: 10,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 3,
    color: '#333',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 5,
    padding: 8,
    fontSize: 14,
    backgroundColor: 'white',
    minHeight: 40,
  },
  buttonContainer: {
    marginBottom: 15,
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  deviceInfo: {
    backgroundColor: '#f0f8ff',
    padding: 12,
    borderRadius: 8,
    marginBottom: 15,
    borderWidth: 1,
    borderColor: '#87ceeb',
  },
  deviceInfoTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 8,
    color: '#333',
  },
  deviceInfoText: {
    fontSize: 12,
    marginBottom: 3,
    color: '#555',
  },
  logsContainer: {
    marginBottom: 20,
    height: 200,
  },
  logsTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    marginBottom: 8,
    color: '#333',
  },
  logsList: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    borderRadius: 5,
    padding: 8,
  },
  logItem: {
    paddingVertical: 3,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  logText: {
    fontSize: 10,
    color: '#333',
  },
});
