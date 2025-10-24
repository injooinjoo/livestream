import { BrowserRouter } from 'react-router-dom';

function App() {
  return (
    <BrowserRouter>
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h1 className="text-4xl font-bold text-gray-900 mb-4">
              OBS Helper
            </h1>
            <p className="text-xl text-gray-600">
              스트리밍 도우미 서비스
            </p>
            <p className="mt-4 text-sm text-gray-500">
              프로젝트 초기화 완료 ✅
            </p>
          </div>
        </div>
      </div>
    </BrowserRouter>
  );
}

export default App;
