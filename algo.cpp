#include <bits/stdc++.h>
using namespace std;

#define R 4
#define E 0.991833
#define U0 25
#define del 20
#define lam 15
#define lamC 30
#define alp 1.0250
#define phi 2.7168
#define gam 0.7

bool cmp(pair<int, float> a, pair<int, float> b)
{
    return a.second < b.second;
}

vector<int> cluster_head(vector<int> arr, vector<int> vel, vector<int> x, vector<int> y)
{
    int n = arr.size();
    int ans[n][n];
    vector<vector<int> > graph;
    for (int i = 0; i < n; i++)
    {
        vector<int> v(n, 0);
        graph.push_back(v);
    }
    int val;
    int L;
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < n; j++)
        {
            if (i != j)
            {
                L = sqrt(pow((y[i] - y[j]), 2) + pow((x[i] - x[j]), 2));
                val = 1 - (((-(vel[i] - vel[j]) * L) + (abs(vel[i] - vel[j]) * R)) / (2 * R * pow((vel[i] - vel[j]), 2)));
                if (val > E)
                {
                    graph[i][j] = 1;
                    graph[j][i] = 1;
                }
            }
        }
    }

    vector<float> xi;
    float tmp;
    float T1 = 0;
    float T2 = 0;
    for (int i = 0; i < n; i++)
    {
        tmp = 0.5 * (1 + tanh(vel[i] / U0));
        xi.push_back(tmp);
        T1 += tmp;
        T2 += tmp * (1 - tmp);
    }
    vector<pair<int, float> > T3;
    float sum1 = 0;
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < n; j++)
        {
            if (i != j && graph[i][j] != 0)
            {
                float f = xi[i] * xi[j];
                sum1 += f;
            }
        }
        T3.push_back(make_pair(i + 1, sum1));
        sum1 = 0;
    }
    sort(T3.begin(), T3.end(), cmp);
    vector<int> ans1;
    ans1.push_back(T3[0].first);
    int graph1[n][n];
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < n; j++)
        {
            graph1[i][j] = graph[i][j];
        }
    }
    graph1[T3[0].first][T3[0].first - 1] = 1;
    graph1[T3[0].first][T3[0].first + 1] = 1;

    for (int i = 0; i < n; i++)
    {
        if (graph1[T3[0].first][i] == 0 && T3[0].first != i)
        {
            ans1.push_back(i);
            if (i > 0)
                graph1[T3[0].first][i - 1] = 1;
            if (i < n - 1)
                graph1[T3[0].first][i + 1] = 1;
        }
    }
    for (auto it : graph)
    {
        for (auto itr : it)
        {
            cout << itr << " ";
        }
        cout << endl;
    }
    for (auto it : ans1)
    {
        cout << it << " ";
    }
    return ans1;
}

string getLine(int ind, vector<int> v, int num)
{
    string str;
    str += to_string(ind);

    str += " ";

    for (int i = 0; i < v.size(); i++)
    {
        str += to_string(v[i]);
        str += " ";
    }
    return str;
}

void kmeans(vector<int> arr, vector<int> vel, vector<int> x, vector<int> y, vector<int> C)
{
    int n = arr.size();
    vector<vector<float> > rho;
    vector<vector<float> > T;
    vector<vector<float> > F;
    for (int i = 0; i < n; i++)
    {
        vector<float> f(n, 0);
        rho.push_back(f);
        T.push_back(f);
        F.push_back(f);
    }
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < n; j++)
        {
            float L = sqrt(pow((y[i] - y[j]), 2) + pow((x[i] - x[j]), 2));
            float delV = vel[i] - vel[j];
            T[i][j] = L / delV;
            if (del * lam < lamC)
            {
                rho[i][j] = (del * lam / lamC) * T[i][j];
            }
            else
            {
                rho[i][j] = T[i][j];
            }
        }
    }
    map<int, vector<int> > Q;
    map<int, bool> mm;
    vector<int> rest;
    for(int i = 0; i < arr.size(); i++){
        bool flag = false;
        for(int j = 0; j < C.size(); j++){
            if(arr[i] == C[j]){
                flag = true;
                break;
            }
        }
        if(!flag){
            rest.push_back(arr[i]);
        }
    }
    // for (auto it : C)
    // {
    //     mm[it] = true;
    // }
    // for (int i = 0; i < arr.size(); i++)
    // {
    //     int max_i = 0;
    //     float maxp = INT_MIN;
    //     for (int j = 0; j < C.size(); j++)
    //     {

    //         if (arr[i] != C[j] && mm[arr[i]] != true)
    //         {
    //             if (maxp < rho[i][j])
    //             {
    //                 maxp = rho[i][j];
    //                 max_i = C[j];
    //             }
    //         }
    //     }
    //     Q[max_i].push_back(arr[i]);
    // }
    for (int i = 0; i < rest.size(); i++)
    {
        int max_i = 0;
        float maxp = INT_MIN;
        for (int j = 0; j < C.size(); j++)
        {
            if (maxp < rho[rest[i]][C[j]])
            {
                maxp = rho[rest[i]][C[j]];
                max_i = C[j];
            }
        }
        Q[max_i].push_back(rest[i]);
    }
    string fil = "";
    int num = 0;
    cout << endl;
    for (auto it : Q)
    {
        string x = getLine(it.first, it.second, num);
        fil += x;
        fil.pop_back();
        fil += '\n';
        num++;
        cout << "Head: " << it.first << endl;
        for(int i = 0; i < it.second.size(); i++){
            cout << it.second[i] << " ";
        }
        cout << endl;
    }
    fil.pop_back();
    ofstream fout;
    fout.open("Input.txt");
    fout << fil << endl;
    fout.close();
    // string to be inserted in file
    // string str;
    // for (int i = 0; i < fil.size(); i++)
    //{
    //    str += fil[i];
    //    str += "\n";
    //}
}

int main()
{
    int n = 10;
    int a[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
    int b[] = {10, 20, -30, 40, -50, 60, 70, -80, 90, 100};
    // int c[] = {0, 1, 1, 2, 2, 4, 5, 6, 6, 8};
    // int d[] = {0, 0, 1, 0, 1, 1, 1, 0, 0, 1};
    int c[] = {7, 3, 1, 2, 2, 4, 5, 6, 6, 8};
    int d[] = {6, 3, 1, 0, 1, 1, 1, 0, 0, 1};
    vector<int> arr(a, a + n);
    vector<int> vel(b, b + n);
    vector<int> x(c, c + n);
    vector<int> y(d, d + n);
    // for(int i=0;i<n;i++){
    //     arr.push_back(i+1);
    //     vel.push_back(c);
    //     cin>
    //     y.push_back(c);
    //
    //     x.push_back(c);
    // }
    vector<int> ch;
    ch = cluster_head(arr, vel, x, y);
    kmeans(arr, vel, x, y, ch);
    return 0;
}