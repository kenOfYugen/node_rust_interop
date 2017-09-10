#include <nan.h>

using v8::Function;
using v8::Local;
using v8::Number;
using v8::Value;
using v8::FunctionTemplate;
using v8::String;
using Nan::AsyncQueueWorker;
using Nan::AsyncWorker;
using Nan::Callback;
using Nan::HandleScope;
using Nan::New;
using Nan::Null;
using Nan::To;
using Nan::GetFunction;
using Nan::Set;

extern "C" {
  double pi_est(double points);
  double ws_pi_est(double points);
}

NAN_METHOD(pi_est_sync) {
  const unsigned int points = info[0]->Uint32Value();
  const double pi = pi_est((double)points);

  info.GetReturnValue().Set(pi);
};

class PiEstWorker : public AsyncWorker {
private:
  const unsigned int points;
  double pi;
public:
  PiEstWorker(Callback *callback, const unsigned int points)
    : AsyncWorker(callback), points(points), pi(0) {}
  ~PiEstWorker() {}

  void Execute() {
    pi = pi_est((double)points);
  }

  void HandleOKCallback () {
    HandleScope scope;

    Local<Value> argv[] = {
        Null()
      , New<Number>(pi)
    };

    callback->Call(2, argv);
  }
};

NAN_METHOD(pi_est_aync) {
  const unsigned int points = To<unsigned int>(info[0]).FromJust();
  Callback *callback = new Callback(info[1].As<Function>());
  AsyncQueueWorker(new PiEstWorker(callback, points));
}

class WsPiEstWorker : public AsyncWorker {
private:
  const unsigned int points;
  double pi;
public:
  WsPiEstWorker(Callback *callback, const unsigned int points)
    : AsyncWorker(callback), points(points), pi(0) {}
  ~WsPiEstWorker() {}

  void Execute() {
    pi = ws_pi_est((double)points);
  }

  void HandleOKCallback () {
    HandleScope scope;

    Local<Value> argv[] = {
        Null()
      , New<Number>(pi)
    };

    callback->Call(2, argv);
  }
};

NAN_METHOD(ws_pi_est_aync) {
  const unsigned int points = To<unsigned int>(info[0]).FromJust();
  Callback *callback = new Callback(info[1].As<Function>());
  AsyncQueueWorker(new WsPiEstWorker(callback, points));
}

NAN_METHOD(ws_pi_est_sync) {
  const unsigned int points = info[0]->Uint32Value();
  const double pi = ws_pi_est((double)points);

  info.GetReturnValue().Set(pi);
};

NAN_MODULE_INIT(InitAll) {
  Set(target, New<String>("piEstRust").ToLocalChecked(),
    GetFunction(New<FunctionTemplate>(pi_est_sync)).ToLocalChecked());

  Set(target, New<String>("wSpiEstRust").ToLocalChecked(),
    GetFunction(New<FunctionTemplate>(ws_pi_est_sync)).ToLocalChecked());

  Set(target, New<String>("piEstRustAsync").ToLocalChecked(),
    GetFunction(New<FunctionTemplate>(pi_est_aync)).ToLocalChecked());

  Set(target, New<String>("wSpiEstRustAsync").ToLocalChecked(),
    GetFunction(New<FunctionTemplate>(ws_pi_est_aync)).ToLocalChecked());
}

NODE_MODULE(addon, InitAll)
